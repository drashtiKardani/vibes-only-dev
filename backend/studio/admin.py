from django.contrib import admin

from . import models


@admin.register(models.Device)
class DeviceAdmin(admin.ModelAdmin):
    list_display = (
        "pk",
        "name",
        "bluetooth_name",
        "is_toy",
        "created_at",
    )
    list_filter = ("is_toy",)
    ordering = ("-created_at",)
    readonly_fields = (
        "created_at",
        "updated_at",
        "deleted_at",
    )
