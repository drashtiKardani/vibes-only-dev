from hippo_shield.models import User
from rest_framework import serializers

from . import models
from reusable.mixins.serializers import (
    RequestAddedSerializerMixin,
    HttpsUrlsOnlySerializerMixin,
)
from users import models
from stories.models import Story
from videos.models import Video


class StaffSerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = models.Staff
        fields = [
            'id',
            'user',
            'first_name',
            'last_name',
            'phone_number',
            'profile_image',
            'email',
            'password',
        ]

    email = serializers.SerializerMethodField()
    password = serializers.CharField(write_only=True, required=False)

    def get_email(self, obj):
        return obj.user.email_password_authentication.email

    def update(self, instance, validated_data):
        staff = super().update(instance, validated_data)
        if "password" in validated_data:
            staff.user.email_password_authentication.set_password(
                validated_data["password"]
            )
            staff.user.email_password_authentication.save()
        return staff


class ProfileSerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = models.Profile
        fields = ['id', 'user', 'first_name', 'last_name', 'profile_image']


class ProfileOnlySerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Profile
        fields = ['id', 'first_name', 'last_name', 'profile_image']


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'date_joined', 'profile']

    profile = ProfileOnlySerializer()


class PushMessageDataSerializer(serializers.Serializer):
    tab = serializers.ChoiceField(
        choices=['home', 'videos'],
        required=False
    )
    story = serializers.IntegerField(required=False)
    video = serializers.IntegerField(required=False)

    def validate_story(self, story_id):
        if not Story.objects.filter(pk=story_id).exists():
            raise serializers.ValidationError(
                "story not found"
            )
        return story_id

    def validate_video(self, video_id):
        if not Video.objects.filter(pk=video_id).exists():
            raise serializers.ValidationError(
                "video not found"
            )
        return video_id


class PushMessageSerializer(serializers.ModelSerializer):
    data = PushMessageDataSerializer(required=False)
    target = serializers.ChoiceField(
        choices=["all", "free", "paid"],
        required=True,
    )
    scheduled_for = serializers.DateTimeField(
        required=False,
        allow_null=True,
    )
    status = serializers.ReadOnlyField()

    class Meta:
        model = models.PushMessage
        fields = [
            'id',
            'title',
            'body',
            'data',
            'target',
            'status',
            'scheduled_for',
            'created_at',
        ]
