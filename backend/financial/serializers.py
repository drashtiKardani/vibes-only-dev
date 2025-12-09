from rest_framework import serializers

from . import models


class GoogleVerifyPurchaseSerializer(serializers.ModelSerializer):
    device_id = serializers.CharField(max_length=30, required=True)

    class Meta:
        model = models.Subscription
        fields = ['token', 'subscription_id', 'device_id']


class GetSubscriptionSerializer(serializers.Serializer):
    device_id = serializers.CharField()


class AppleVerifyPurchaseSerializer(serializers.Serializer):
    token = serializers.CharField()
    device_id = serializers.CharField()


class PromotionSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Promotion
        exclude = ("deleted_at",)


class PromotionVisitInputSerializer(serializers.Serializer):
    uid = serializers.UUIDField()
