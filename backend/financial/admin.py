from django.contrib import admin

from . import models
from reusable import admins as reu_admins



@admin.register(models.Subscription)
class SubscriptionAdmin(reu_admins.ReadOnlyAdminDateFields, admin.ModelAdmin):
    list_display = (
        "pk",
        "device_id",
        "subscription_id",
        "app_platform",
        "exp_date",
        "created_at",
    )
    search_fields = ("device_id__iexact",)


@admin.register(models.Promotion)
class PromotionAdmin(reu_admins.ReadOnlyAdminDateFields, admin.ModelAdmin):
    list_display = (
        "pk",
        "title",
        "subscription_type",
        "code",
        "created_at",
    )
    readonly_fields = (
        "uid",
        "visit_count",
        "usage_count",
        "created_at",
        "updated_at",
        "deleted_at",
    )
