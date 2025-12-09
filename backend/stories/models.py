import uuid
import mutagen
import logging
import tempfile
import ffmpeg
import shortuuid


from django.utils import timezone
from django.core.files import File
from django.db import models, transaction
from model_utils import FieldTracker
from sortedm2m.fields import SortedManyToManyField


from . import tasks
from users.models import Profile
from videos.utils.aws import get_boto_session
from hippo_heart.models import PublisherMixin
from reusable.models import BaseModel, new_resized_image
from reusable.aws import transcribe_create_job


logger = logging.getLogger(__name__)


class Character(PublisherMixin, BaseModel):
    first_name = models.CharField(max_length=255)
    last_name = models.CharField(max_length=255, blank=True, null=True)
    bio = models.TextField(blank=True, null=True)
    profile_image = models.ImageField(
        upload_to='stories/character/profile_image/', null=True, blank=True
    )
    show_on_homepage = models.BooleanField(null=True, blank=True)
    order = models.PositiveIntegerField(default=0)
    tracker = FieldTracker()

    class Meta:
        ordering = ('order', 'id')

    @property
    def images_changed(self):
        return self.tracker.has_changed('profile_image')

    def __str__(self):
        return f'{self.first_name} - {self.last_name}'

    def process_images(self):
        for field_name in ['profile_image']:
            image_field = getattr(self, field_name)
            if image_field:
                changed, img_temp = new_resized_image(image_field.url)
                if not changed:
                    continue
                name = f'con_{image_field.name.split("/")[-1]}'
                setattr(self, field_name, File(img_temp, name))
        self.save()

    def save(self, *args, **kwargs):
        from . import tasks

        with transaction.atomic():
            if self.images_changed:
                transaction.on_commit(
                    lambda: tasks.process_character_images.delay(self.pk)
                )
            super().save(*args, **kwargs)


class Category(PublisherMixin):
    class Meta:
        verbose_name_plural = 'categories'

    title = models.CharField(max_length=255)
    image = models.ImageField(
        upload_to='stories/category/image/', blank=True, null=True
    )
    android_image = models.ImageField(
        upload_to='stories/category/image/android/', blank=True, null=True
    )
    tile_view = models.BooleanField(default=False)
    background_color = models.CharField(max_length=255, blank=True, null=True)
    published_date = models.DateTimeField(null=True, blank=True)
    related_categories = models.ManyToManyField('Category', blank=True)
    tracker = FieldTracker()

    @property
    def images_changed(self):
        return (
            self.tracker.has_changed('image') or self.tracker.has_changed('android_image')
        )

    def __str__(self):
        return self.title

    def process_images(self):
        for field_name in ['image', 'android_image']:
            image_field = getattr(self, field_name)
            if image_field:
                changed, img_temp = new_resized_image(image_field.url)
                if not changed:
                    continue
                name = image_field.name.split('/')[-1]
                setattr(self, field_name, File(img_temp, name))
        self.save()

    def save(self, *args, **kwargs):
        from . import tasks

        with transaction.atomic():
            if self.images_changed:
                transaction.on_commit(
                    lambda: tasks.process_category_images.delay(self.pk)
                )
            super().save(*args, **kwargs)


class Story(PublisherMixin, BaseModel):
    class Meta:
        verbose_name_plural = 'stories'

    title = models.CharField(max_length=255)
    description = models.TextField()
    short_description = models.TextField()
    uid = models.UUIDField(default=uuid.uuid4, unique=True)
    published_date = models.DateTimeField(null=True, blank=True)
    new = models.BooleanField(null=True, blank=True)
    paid = models.BooleanField(default=False)
    featured = models.BooleanField(null=True, blank=True)
    trending = models.BooleanField(null=True, blank=True)
    top_10 = models.BooleanField(null=True, blank=True)
    staff_pick = models.BooleanField(null=True, blank=True)
    audio = models.FileField(upload_to='stories/story/audio/', blank=True, null=True)
    audio_length_seconds = models.IntegerField(default=0, blank=True)
    audio_preview = models.FileField(upload_to='preview/', blank=True, null=True)
    transcript = models.TextField(blank=True, null=True)
    transcript_job_id = models.CharField(max_length=255, blank=True, null=True)
    beat = models.TextField(blank=True, null=True)
    characters = models.ManyToManyField(Character, related_name='stories', blank=True)
    categories = models.ManyToManyField(Category, related_name='stories', blank=True)
    favorite_by = SortedManyToManyField(
        Profile, related_name='favorite_stories', blank=True
    )
    view_count_hour = models.PositiveBigIntegerField(default=0)
    view_count_day = models.PositiveBigIntegerField(default=0)
    view_count_total = models.PositiveBigIntegerField(default=0)
    image_processing_is_done = models.BooleanField(null=True, blank=True, default=False)
    audio_processing_is_done = models.BooleanField(null=True, blank=True, default=False)
    tracker = FieldTracker()

    image_cover = models.ImageField(
        upload_to='stories/story/image_cover/', null=True, blank=True
    )
    image_full = models.ImageField(
        upload_to='stories/story/image_full/', null=True, blank=True
    )
    image_showcase_extended = models.ImageField(
        upload_to='stories/story/image_showcase_extended/', null=True, blank=True
    )
    image_showcase_tall = models.ImageField(
        upload_to='stories/story/image_showcase_tall/', null=True, blank=True
    )
    image_showcase_medium = models.ImageField(
        upload_to='stories/story/image_showcase_medium/', null=True, blank=True
    )
    image_showcase_small = models.ImageField(
        upload_to='stories/story/image_showcase_small/', null=True, blank=True
    )

    def __str__(self):
        return f"({self.pk} - {self.title})"

    @property
    def studio_link(self):
        return f"https://vibes.rekab.org/?uid={self.uid}"

    @property
    def images_changed(self):
        return (
            self.tracker.has_changed('image_cover')
            or self.tracker.has_changed('image_full')
            or self.tracker.has_changed('image_showcase_extended')
            or self.tracker.has_changed('image_showcase_tall')
            or self.tracker.has_changed('image_showcase_medium')
            or self.tracker.has_changed('image_showcase_small')
        )

    @property
    def is_processes_done(self):
        if self.audio and not self.transcript:
            return False
        return (
            self.image_processing_is_done == True
            and self.audio_processing_is_done == True
        )

    def process_audio(self):
        if not self.audio:
            return
        client = get_boto_session().client('transcribe', region_name='us-east-2')
        job_data = transcribe_create_job(
            client,
            transcription_job_name=f"story_{uuid.uuid4()}",
            file_url=self.audio.url,
        )
        self.transcript_job_id = job_data['TranscriptionJobName']
        self.transcript = None
        self.save()

    def process_images(self):
        for field_name in [
            'image_cover',
            'image_full',
            'image_showcase_extended',
            'image_showcase_tall',
            'image_showcase_medium',
            'image_showcase_small',
        ]:
            image_field = getattr(self, field_name)
            if image_field:
                changed, img_temp = new_resized_image(image_field.url)
                if not changed:
                    continue
                name = image_field.name.split('/')[-1]
                setattr(self, field_name, File(img_temp, name))
        self.image_processing_is_done = True

    def process_audio_preview(self):
        if not self.audio or not self.audio.file:
            self.audio_preview = None
            self.save()
            return None

        preview_extension = '.mp3'
        preview_duration = 30   # in seconds
        logger.debug(
            "starting to process audio preview file [story=%s, audio=%s]",
            self, self.audio,
        )
        with tempfile.NamedTemporaryFile(mode="w+b", suffix=preview_extension) as tmpfile:
            (
                ffmpeg.input(self.audio.url, ss=0)
                .audio.filter(
                    "silenceremove", start_periods=1, start_threshold="-70dB"
                )
                .filter(
                    "atrim", duration=preview_duration,
                )
                .filter(
                    "afade", t="out", st=preview_duration - 1, d=1,
                )
                .output(tmpfile.name)
                .overwrite_output()
                .run()
            )
            preview_filename = f"{shortuuid.random(7)}{preview_extension}"
            self.audio_preview.save(
                preview_filename,
                File(tmpfile),
                save=True,
            )
            logger.debug(
                "finished processing audio preview file [story=%s, audio_preview=%s]",
                self, self.audio_preview,
            )

    def save(self, *args, **kwargs):
        created = self.pk is None
        with transaction.atomic():
            if created:
                self.published_date = timezone.localtime()
                self.date_process_started = timezone.localtime()
            if self.images_changed:
                self.image_processing_is_done = False
                transaction.on_commit(lambda: tasks.process_images.delay(self.pk))
            if self.tracker.has_changed('audio'):
                audio_info = mutagen.File(self.audio).info
                self.audio_length_seconds = int(audio_info.length)
                self.audio_processing_is_done = False
                transaction.on_commit(lambda: tasks.process_transcript.delay(self.pk))
            super().save(*args, **kwargs)


class Section(PublisherMixin):
    class ContentType(models.TextChoices):
        STAFF_PICKED = 'STAFF_PICKED', 'Staff Picked'
        FEATURED_CONTENT = 'FEATURED_CONTENT', 'Featured Content'
        TRENDING = 'TRENDING', 'Trending'
        NEW_STORIES = 'NEW_STORIES', 'New Stories'
        POPULAR_STORIES = 'POPULAR_STORIES', 'Popular Stories'
        RECENTLY_PLAYED = 'RECENTLY_PLAYED', 'Recently Played'
        CHARACTERS = 'CHARACTERS', 'Characters'
        TOP_CATEGORIES = 'TOP_CATEGORIES', 'Top Categories'

    title = models.CharField(max_length=255)
    content_type = models.CharField(
        max_length=255, choices=ContentType.choices, default=ContentType.STAFF_PICKED
    )
    style = models.CharField(max_length=255)
    stories = SortedManyToManyField(Story, blank=True, related_name='sections')

    def characters(self, state=None):
        if self.content_type == self.ContentType.CHARACTERS:
            qs = Character.objects.all()
            if state:
                qs = qs.filter(state=state)
            return qs.order_by('order', 'id')[: max(qs.count(), 10)]
        return []

    def categories(self, state=None):
        if self.content_type == self.ContentType.TOP_CATEGORIES:
            qs = Category.objects.all()
            if state:
                qs = qs.filter(state=state)
            return qs.order_by(
                models.F('published_date').desc(nulls_last=True),
                'id'
            )[: max(qs.count(), 10)]
        return []

    def containing_stories(self, state=None):
        qs = Story.objects.all()
        if self.content_type == Section.ContentType.FEATURED_CONTENT:
            qs = qs.filter(featured=True)
        elif self.content_type == Section.ContentType.STAFF_PICKED:
            qs = qs.filter(staff_pick=True)
        elif self.content_type == Section.ContentType.NEW_STORIES:
            qs = qs.filter(new=True)
        elif self.content_type == Section.ContentType.TRENDING:
            qs = qs.filter(trending=True)
        elif self.content_type == Section.ContentType.RECENTLY_PLAYED:
            qs = qs.none()
        elif self.content_type == Section.ContentType.POPULAR_STORIES:
            qs = qs.filter(top_10=True)
        elif self.content_type == Section.ContentType.TOP_CATEGORIES:
            qs = qs.none()
        elif self.content_type == Section.ContentType.CHARACTERS:
            qs = qs.none()
        if state:
            qs = qs.filter(state=state)
        return qs.order_by('-published_date', 'id')[: max(10, qs.count())]

    def __str__(self):
        return self.title


class Home(PublisherMixin):
    title = models.CharField(max_length=255)
    sections = SortedManyToManyField(Section, blank=True, related_name='homes')

    def __str__(self):
        return self.title
