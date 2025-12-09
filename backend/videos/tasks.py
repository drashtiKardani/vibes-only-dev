import uuid
from cv2 import cv2
from urllib.request import urlopen
from toolz import itertoolz, dicttoolz
from operator import itemgetter

from django.db import transaction
from django.db.models import F
from celery import Task
from celery.utils.log import get_task_logger

from . import models
from videos.utils import aws
from vibes_only_backend.celery_settings import app
from reusable.aws import transcribe_get_job, transcribe_create_job
from hit_count.engines import RedisEngine as HitCounter
from hit_count.enums import TimeWindow
from hit_count.utils import is_zero_hour_at_timezone

MEDIACONVERT_URL = "https://fkuulejsc.mediaconvert.us-east-2.amazonaws.com"


logger = get_task_logger(__name__)


class BaseTaskWithRetry(Task):
    autoretry_for = (Exception,)
    retry_kwargs = {"max_retries": 10}
    retry_backoff = 5
    retry_jitter = True


@app.task()
def send_to_aws(video_id):
    with transaction.atomic():
        video = models.Video.objects.select_for_update().get(id=video_id)
        video_file = cv2.VideoCapture(video.file.url)
        video.height = video_file.get(cv2.CAP_PROP_FRAME_HEIGHT)
        video.width = video_file.get(cv2.CAP_PROP_FRAME_WIDTH)
        video.make_unprocessed()
        video.save()
        start_vibes_video_quality_convert.delay(video_id)


@app.task()
def start_vibes_video_quality_convert(video_id):
    with transaction.atomic():
        client = aws.get_boto_session().client(
            'mediaconvert', endpoint_url=MEDIACONVERT_URL, region_name='us-east-2'
        )
        job_data = aws.mediaconvert_clean_job(
            aws.mediaconvert_get_job_template(client, "vibes_video_quality_convert")
        )
        video = models.Video.objects.select_for_update().get(id=video_id)
        job_data = aws.mediaconvert_set_input(job_data, path=video.file.url)
        job_data = aws.mediaconvert_move_logo(job_data, width=video.width)
        video.quality_convert_job_id = aws.mediaconvert_create_job(client, job_data)
        video.save()


@app.task(base=BaseTaskWithRetry)
def check_vibes_video_quality_convert(video_id):
    with transaction.atomic():
        video = models.Video.objects.select_for_update().get(id=video_id)
        video.quality_convert_job_finished = True
        video.save()
        start_vibes_video_short_trimmer.delay(video_id=video_id)
        start_vibes_video_transcript.delay(video_id=video_id)


@app.task()
def start_vibes_video_short_trimmer(video_id):
    with transaction.atomic():
        client = aws.get_boto_session().client(
            'mediaconvert', endpoint_url=MEDIACONVERT_URL, region_name='us-east-2'
        )
        job_data = aws.mediaconvert_clean_job(
            aws.mediaconvert_get_job_template(client, "vibes_video_short_trimmer")
        )
        video = models.Video.objects.select_for_update().get(id=video_id)
        job_data = aws.mediaconvert_set_input(
            job_data, path=video.signed_final_file_url
        )
        video.short_trimmer_job_id = aws.mediaconvert_create_job(client, job_data)
        video.save()


@app.task(base=BaseTaskWithRetry)
def check_vibes_video_short_trimmer(video_id):
    with transaction.atomic():
        video = models.Video.objects.select_for_update().get(id=video_id)
        video.short_trimmer_job_finished = True
        video.save()


@app.task()
def start_vibes_video_transcript(video_id):
    with transaction.atomic():
        client = aws.get_boto_session().client('transcribe', region_name='us-east-2')
        video = models.Video.objects.select_for_update().get(id=video_id)
        if not video.file:
            return False
        job_data = transcribe_create_job(
            client,
            transcription_job_name=f"video_{uuid.uuid4()}",
            file_url=video.file.url,
            media_format=video.file.name.split('.')[-1],
        )
        video.transcript_job_id = job_data['TranscriptionJobName']
        video.transcript_job_finished = False
        video.transcript = None
        video.save()


@app.task(base=BaseTaskWithRetry)
def check_vibes_video_transcript(video_id):
    with transaction.atomic():
        video = models.Video.objects.select_for_update().get(id=video_id)
        client = aws.get_boto_session().client('transcribe', region_name='us-east-2')
        job_data = transcribe_get_job(client, video.transcript_job_id)
        if job_data['TranscriptionJobStatus'] == 'COMPLETED':
            subtitle_url = job_data['Subtitles']['SubtitleFileUris'][0]
            with urlopen(subtitle_url) as srt_file:
                content = srt_file.read().decode()
            video.transcript = content
            video.transcript_job_finished = True
            video.save()


@app.task()
def process_channel_images(channel_id):
    with transaction.atomic():
        story = models.Channel.objects.select_for_update().get(id=channel_id)
        story.process_images()


@app.task()
def process_video_images(video_id):
    with transaction.atomic():
        story = models.Video.objects.select_for_update().get(id=video_id)
        story.process_images()


@app.task()
def update_view_counts():
    hit_counter = HitCounter()
    hour_counts = hit_counter.get_counts('video', TimeWindow.Hour, offset=-1)
    day_counts = hit_counter.get_counts('video', TimeWindow.Day)
    grouped_day_counts = itertoolz.groupby(itemgetter(0), day_counts)
    logger.debug('Video hit counts hour=%s, day=%s', hour_counts, day_counts)

    with transaction.atomic():
        for (pk, view_count_hour) in hour_counts:
            if not pk or not view_count_hour:
                continue
            try:
                view_count_day = dicttoolz.get_in([pk, 0, 1], grouped_day_counts, default=0)
                models.Video.objects.filter(
                    pk=pk,
                ).update(
                    view_count_hour=view_count_hour,
                    view_count_day=view_count_day,
                    view_count_total=F('view_count_total') + view_count_hour,
                )
            except Exception as ex:
                logger.error('Error updating video view counts, pk=%s error=%s', pk, ex)

        try:
            reset_counts = dict(view_count_hour=0)
            if is_zero_hour_at_timezone('America/Toronto'):
                reset_counts.update(view_count_day=0)
            models.Video.objects.exclude(
                pk__in=[item[0] for item in hour_counts],
            ).update(**reset_counts)
        except Exception as ex:
            logger.error('Error reseting video view counts, error=%s', pk, ex)
