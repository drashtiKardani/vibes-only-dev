from django.contrib import admin

from . import models
from reusable import admins as reu_admins


@admin.register(models.PushMessage)
class PushMessageAdmin(reu_admins.ReadOnlyAdminClass, admin.ModelAdmin):
    list_display = ("pk", "title", "target", "status", "scheduled_for", "created_at")
    search_fields = ("title", "body")
    readonly_fields = (
        "task_id",
        "status",
        "result",
        "scheduled_for",
        "created_at",
        "updated_at",
    )


@admin.register(models.Profile)
class ProfileAdmin(admin.ModelAdmin):
    list_display = ("pk", "first_name", "last_name", "two_fa_code", "get_email")


@admin.register(models.Staff)
class StaffAdmin(admin.ModelAdmin):
    list_display = (
        "pk",
        "first_name",
        "last_name",
        "two_fa_code",
        "get_email",
        "phone_number",
    )
