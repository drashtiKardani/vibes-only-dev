from django.contrib import admin

from . import models, tasks


@admin.register(models.Channel)
class ChannelAdmin(admin.ModelAdmin):
    list_display = ("pk", "title", "state", "published_date")


@admin.register(models.Video)
class VideoAdmin(admin.ModelAdmin):
    list_display = (
        "pk",
        "title",
        "file",
        "state",
        "paid",
        "get_q_convert_status",
        "get_transcript_status",
        "get_short_trim_status",
        "published_date",
    )
    list_filter = (
        "state",
        "paid",
    )
    readonly_fields = (
        "quality_convert_job_id",
        "short_trimmer_job_id",
        "transcript_job_id",
        "quality_convert_job_finished",
        "short_trimmer_job_finished",
        "transcript_job_finished",
        "processed_files",
        "video_640",
        "video_1024",
        "video_1920",
    )
    raw_id_fields = ("liked_by",)

    @admin.display(description="q-convert")
    def get_q_convert_status(self, instance):
        return instance.quality_convert_job_finished

    @admin.display(description="transcript")
    def get_transcript_status(self, instance):
        return instance.transcript_job_finished

    @admin.display(description="short-trim")
    def get_short_trim_status(self, instance):
        return instance.short_trimmer_job_finished

    def process_video(self, request, queryset):
        for video in queryset:
            tasks.send_to_aws.delay(video.pk)

    actions = [process_video]


@admin.register(models.VideoCreator)
class VideoCreatorAdmin(admin.ModelAdmin):
    list_display = (
        "pk",
        "name",
        "photo",
        "is_staff_choice",
        "date_created",
    )
    list_filter = (
        "is_staff_choice",
    )
    search_fields = (
        "name",
    )
    readonly_fields = (
        "date_created",
    )
