from django.contrib import admin

from . import models, tasks
from reusable import admins as reu_admins


@admin.register(models.Story)
class StoryAdmin(reu_admins.ReadOnlyContentFields, admin.ModelAdmin):
    list_display = (
        "pk",
        "title",
        "state",
        "paid",
        "audio",
        "get_length",
        "image_processing_is_done",
        "audio_processing_is_done",
        "created_at",
    )
    list_filter = (
        "state",
        "paid",
    )
    readonly_fields = ("deleted_at", "uid", "transcript_job_id")
    raw_id_fields = ("favorite_by",)

    @admin.display(description="length")
    def get_length(self, instance):
        return instance.audio_length_seconds

    def process_images(self, request, queryset):
        for story in queryset:
            tasks.process_images.delay(story.pk)

    def calculate_audio_length(self, request, queryset):
        for story in queryset:
            tasks.update_story_duration.delay(story.pk)

    def generate_audio_preview(self, request, queryset):
        for story in queryset:
            tasks.update_audio_preview.delay(story.pk)

    actions = [process_images, calculate_audio_length, generate_audio_preview]


@admin.register(models.Character)
class CharacterAdmin(reu_admins.ReadOnlyContentFields, admin.ModelAdmin):
    list_display = (
        "pk",
        "first_name",
        "last_name",
        "state",
        "order",
        "profile_image",
        "created_at",
    )
    readonly_fields = ("deleted_at",)

    def process_images(self, request, queryset):
        for character in queryset:
            tasks.process_character_images.delay(character.pk)

    actions = [process_images]


@admin.register(models.Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ("pk", "title", "tile_view", "published_date", "image")

    def process_images(self, request, queryset):
        for category in queryset:
            tasks.process_category_images.delay(category.pk)

    actions = [process_images]


@admin.register(models.Home)
class HomeAdmin(admin.ModelAdmin):
    list_display = ("pk", "title")


@admin.register(models.Section)
class SectionAdmin(admin.ModelAdmin):
    list_display = ("pk", "title", "content_type", "style", "state")
