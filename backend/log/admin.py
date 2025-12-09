from django.contrib import admin

from . import models
from reusable import admins as reu_admins


@admin.register(models.TwilioLog)
class TwilioLogAdmin(reu_admins.ReadOnlyAdminClass, admin.ModelAdmin):
    list_display = ("pk", "to", "created_at")


@admin.register(models.AWSLog)
class AWSLogAdmin(reu_admins.ReadOnlyAdminClass, admin.ModelAdmin):
    list_display = ("pk", "source", "video", "status", "created_at")
    list_filter = ("source",)
    raw_id_fields = ("video",)
