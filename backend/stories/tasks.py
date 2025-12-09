import requests
from io import BytesIO
from urllib.request import urlopen
from toolz import itertoolz, dicttoolz
from operator import itemgetter

from celery import Task
from celery.utils.log import get_task_logger
from django.db import transaction
from django.db.models import F
from django.core.files import File

from . import models
from reusable.aws import transcribe_get_job
from hit_count.engines import RedisEngine as HitCounter
from hit_count.enums import TimeWindow
from hit_count.utils import is_zero_hour_at_timezone
from videos.utils.aws import get_boto_session
from vibes_only_backend.celery_settings import app


logger = get_task_logger(__name__)


class BaseTaskWithRetry(Task):
    autoretry_for = (Exception,)
    retry_kwargs = {"max_retries": 10}
    retry_backoff = 5
    retry_jitter = True


@app.task()
def process_images(story_id):
    with transaction.atomic():
        story = models.Story.objects.select_for_update().get(id=story_id)
        story.process_images()
        story.save()


@app.task()
def process_character_images(character_id):
    with transaction.atomic():
        character = models.Character.objects.select_for_update().get(id=character_id)
        character.process_images()


@app.task()
def process_category_images(category_id):
    with transaction.atomic():
        category = models.Category.objects.select_for_update().get(id=category_id)
        category.process_images()


@app.task()
def process_transcript(story_id):
    with transaction.atomic():
        story = models.Story.objects.select_for_update().get(id=story_id)
        story.process_audio()
        story.process_audio_preview()


@app.task(base=BaseTaskWithRetry)
def check_process_transcript(story_id):
    client = get_boto_session().client("transcribe", region_name="us-east-2")
    with transaction.atomic():
        story = models.Story.objects.select_for_update().get(id=story_id)
        job_data = transcribe_get_job(client, story.transcript_job_id)
        if job_data["TranscriptionJobStatus"] == "COMPLETED":
            subtitle_url = job_data["Subtitles"]["SubtitleFileUris"][0]
            with urlopen(subtitle_url) as srt_file:
                content = srt_file.read().decode()
            story.transcript = content
            story.audio_processing_is_done = True
            story.save()


@app.task()
def update_story_duration(story_id):
    story = models.Story.objects.get(id=story_id)
    res = requests.get(story.audio.url)
    fp = BytesIO()
    fp.write(res.content)
    story.audio.save(story.audio.name.split("/")[-1], File(fp))


@app.task()
def update_view_counts():
    hit_counter = HitCounter()
    hour_counts = hit_counter.get_counts("story", TimeWindow.Hour, offset=-1)
    day_counts = hit_counter.get_counts("story", TimeWindow.Day)
    grouped_day_counts = itertoolz.groupby(itemgetter(0), day_counts)
    logger.debug("Story hit counts hour=%s, day=%s", hour_counts, day_counts)

    with transaction.atomic():
        for (pk, view_count_hour) in hour_counts:
            if not pk or not view_count_hour:
                continue
            try:
                view_count_day = dicttoolz.get_in(
                    [pk, 0, 1], grouped_day_counts, default=0
                )
                models.Story.objects.filter(pk=pk,).update(
                    view_count_hour=view_count_hour,
                    view_count_day=view_count_day,
                    view_count_total=F("view_count_total") + view_count_hour,
                )
            except Exception as ex:
                logger.error("Error updating story view counts, pk=%s error=%s", pk, ex)

        try:
            reset_counts = dict(view_count_hour=0)
            if is_zero_hour_at_timezone("America/Toronto"):
                reset_counts.update(view_count_day=0)
            models.Story.objects.exclude(
                pk__in=[item[0] for item in hour_counts],
            ).update(**reset_counts)
        except Exception as ex:
            logger.error("Error reseting story view counts, error=%s", pk, ex)
