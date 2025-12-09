import uuid
import logging

from django.conf import settings
from django.utils import timezone
from django.core.files import File
from django.db import models, transaction
from model_utils import FieldTracker
from sortedm2m.fields import SortedManyToManyField

from . import tasks
from .utils import aws
from users.models import Profile
from reusable.models import new_resized_image
from hippo_heart.models import PublisherMixin


logger = logging.getLogger(__name__)


class Channel(PublisherMixin):
    title = models.CharField(max_length=255)
    image = models.ImageField(upload_to='videos/channel/image/')
    description = models.TextField()
    published_date = models.DateTimeField(null=True, blank=True)
    is_staff_choice = models.BooleanField(default=False)
    order = models.PositiveIntegerField(default=0)
    favorite_by = SortedManyToManyField(
        Profile, related_name='favorite_channels', blank=True
    )
    tracker = FieldTracker()

    @property
    def images_changed(self):
        return self.tracker.has_changed('image')

    def __str__(self):
        return self.title

    def process_images(self):
        for field_name in ['image']:
            image_field = getattr(self, field_name)
            if image_field:
                changed, img_temp = new_resized_image(image_field.url)
                if not changed:
                    continue
                name = image_field.name.split('/')[-1]
                setattr(self, field_name, File(img_temp, name))
        self.save()

    def save(self, *args, **kwargs):
        with transaction.atomic():
            created = self.pk is None
            if created:
                self.published_date = timezone.localtime()
            if self.images_changed:
                transaction.on_commit(
                    lambda: tasks.process_channel_images.delay(self.pk)
                )
            super().save(*args, **kwargs)

    class Meta:
        ordering = ("order", "-date_created",)


class Video(PublisherMixin):
    title = models.CharField(max_length=255)
    uid = models.UUIDField(default=uuid.uuid4)
    channels = models.ManyToManyField(Channel, related_name='videos')
    paid = models.BooleanField(default=False)
    file = models.FileField(upload_to='videos/video/file/', null=True, blank=True)
    height = models.IntegerField(blank=True, null=True)
    width = models.IntegerField(blank=True, null=True)
    caption = models.TextField(default=None, null=True, blank=True)
    transcript = models.TextField(blank=True, null=True)
    liked_by = models.ManyToManyField(Profile, related_name='liked_videos', blank=True)
    published_date = models.DateTimeField(null=True, blank=True)
    thumbnail = models.ImageField(
        upload_to='videos/video/thumbnail/', blank=True, null=True
    )
    trend_image = models.ImageField(
        upload_to='videos/video/trend/', blank=True, null=True
    )
    quality_convert_job_id = models.CharField(max_length=255, blank=True, null=True)
    quality_convert_job_finished = models.BooleanField(default=False, null=True)
    short_trimmer_job_id = models.CharField(max_length=255, blank=True, null=True)
    short_trimmer_job_finished = models.BooleanField(default=False, null=True)
    transcript_job_id = models.CharField(max_length=255, blank=True, null=True)
    transcript_job_finished = models.BooleanField(default=False, null=True)
    is_trend = models.BooleanField(default=False)
    is_favorite = models.BooleanField(default=False)
    view_count_hour = models.PositiveBigIntegerField(default=0)
    view_count_day = models.PositiveBigIntegerField(default=0)
    view_count_total = models.PositiveBigIntegerField(default=0)
    watch_count_total = models.PositiveBigIntegerField(default=0)
    exclude_android = models.BooleanField(default=False)
    creator = models.ForeignKey(
        "VideoCreator",
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="videos",
        related_query_name="video",
    )

    tracker = FieldTracker()

    @property
    def images_changed(self):
        return self.tracker.has_changed('thumbnail')

    @property
    def file_name(self):
        return self.file.name.split('/')[-1]

    @property
    def file_extension(self):
        return self.file_name.split('.')[-1]

    @property
    def final_file_url(self):
        if not self.quality_convert_job_finished:
            return None
        temp1 = 'https://d1ib4awwsyt3an.cloudfront.net'
        temp2 = f'/videos/video/s3_final_file/{self.file_name}'
        temp = temp1 + temp2
        return '-final.mp4'.join(temp.rsplit(f'.{self.file_extension}', 1))

    @property
    def signed_final_file_url(self):
        url = self.final_file_url
        return aws.generate_signed_url_of_cdn_url(url, 5)

    @property
    def processed_files(self):
        data = {}
        final_file = self.final_file_url
        if not final_file:
            return data
        if self.quality_convert_job_finished:
            data['final'] = final_file
            data['final-360x640'] = final_file.replace(
                '-final.mp4', '-final-360x640.mp4'
            )
            data['final-576x1024'] = final_file.replace(
                '-final.mp4', '-final-576x1024.mp4'
            )
            data['final-1080x1920'] = final_file.replace(
                '-final.mp4', '-final-1080x1920.mp4'
            )
        if self.short_trimmer_job_finished:
            data['first_frame'] = final_file.replace(
                's3_final_file', 's3_first_frame_file'
            ).replace('-final.mp4', '-final-first-frame.0000000.jpg')
            data['short'] = final_file.replace(
                's3_final_file', 's3_short_file'
            ).replace('-final.mp4', '-final-short.mp4')
        return self.signed_processed_files(data)

    @property
    def video_640(self):
        return self.processed_files.get('final-360x640')

    @property
    def video_1024(self):
        return self.processed_files.get('final-576x1024')

    @property
    def video_1920(self):
        return self.processed_files.get('final-1080x1920')

    @property
    def short_video(self):
        if self.short_trimmer_job_finished:
            return self.processed_files['short']

    def signed_processed_files(self, data):
        for key in data.keys():
            data[key] = aws.generate_signed_url_of_cdn_url(data[key], 1)
        return data

    def video_quality_status(self):
        if self.quality_convert_job_finished:
            return 'Finished'
        if self.quality_convert_job_finished is None:
            return 'Failed'
        return 'Processing'

    def video_short_version_status(self):
        if self.short_trimmer_job_finished:
            return 'Finished'
        if self.short_trimmer_job_finished is None:
            return 'Failed'
        return 'Processing'

    def transcript_status(self):
        if self.transcript_job_finished:
            return 'Finished'
        if self.transcript_job_finished is None:
            return 'Failed'
        return 'Processing'

    def make_unprocessed(self):
        self.quality_convert_job_id = None
        self.short_trimmer_job_id = None
        self.transcript_job_id = None
        self.quality_convert_job_finished = False
        self.short_trimmer_job_finished = False
        self.transcript_job_finished = False

    def is_processes_done(self):
        return (
            self.quality_convert_job_finished
            and self.short_trimmer_job_finished
            and self.transcript_job_finished
        )

    def process_images(self):
        for field_name in ['thumbnail']:
            image_field = getattr(self, field_name)
            if image_field:
                changed, img_temp = new_resized_image(image_field.url)
                if not changed:
                    continue
                name = image_field.name.split('/')[-1]
                setattr(self, field_name, File(img_temp, name))
        self.save()

    def __str__(self):
        return self.title

    def save(self, *args, **kwargs):
        created = self.pk is None
        if created and self.published_date is None:
            self.published_date = timezone.localtime()
        with transaction.atomic():
            if self.tracker.has_changed('file'):
                transaction.on_commit(lambda: tasks.send_to_aws.delay(self.pk))
            if self.images_changed:
                transaction.on_commit(lambda: tasks.process_video_images.delay(self.pk))
            super().save(*args, **kwargs)

    class Meta:
        ordering = ("-date_created",)


class MediaUpload(models.Model):
    name = models.CharField(max_length=255, blank=True, null=True)
    file = models.FileField(
        upload_to='videos/media_upload/file/', blank=True, null=True
    )
    image = models.ImageField(
        upload_to='videos/media_upload/file/', blank=True, null=True
    )


class VideoCreator(models.Model):
    name = models.CharField(max_length=512)
    photo = models.ImageField(
        upload_to='videos/creator/', blank=True, null=True
    )
    bio = models.TextField(blank=True)
    is_staff_choice = models.BooleanField(default=False)
    order = models.PositiveIntegerField(default=0)
    date_created = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ("order", "id")

    def __str__(self):
        return self.name
