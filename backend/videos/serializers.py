from crum import get_current_user
from rest_framework import serializers

from reusable.mixins.serializers import (
    RequestAddedSerializerMixin,
    HttpsUrlsOnlySerializerMixin,
)
from reusable.views import is_application_request, is_android_request
from videos.models import Channel, Video, MediaUpload, VideoCreator
from reusable.mixins.serializers.models import PublisherSerializerMixin


class ChannelSerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = Channel
        fields = [
            'id',
            'title',
            'image',
            'description',
            'videos_count',
            'video_list',
            'is_staff_choice',
            'order',
            'favorite_by_me',
            'style',
            'published_date',
        ] + PublisherSerializerMixin.FIELDS

    date_created = serializers.DateTimeField(read_only=True)
    videos_count = serializers.SerializerMethodField()
    video_list = serializers.SerializerMethodField()
    favorite_by_me = serializers.SerializerMethodField()
    style = serializers.SerializerMethodField()

    def get_style(self, obj):
        return 'SHOWCASE_MEDIUM'

    def get_videos_count(self, obj):
        result = obj.videos.all()
        if is_application_request():
            result = result.exclude(state=obj.State.CREATED)
        if is_android_request():
            result = result.exclude(exclude_android=True)
        return result.count()

    def get_video_list(self, obj):
        result = obj.videos.all()
        if is_application_request():
            result = result.exclude(state=obj.State.CREATED)
        if is_android_request():
            result = result.exclude(exclude_android=True)
        return ChannelVideoSerializer(result.order_by("-date_created"), many=True).data

    def get_favorite_by_me(self, obj):
        if get_current_user() and hasattr(get_current_user(), 'profile'):
            return obj.favorite_by.filter(id=get_current_user().profile.id).exists()
        return False


class PublishedChannelSerializer(ChannelSerializer):
    def get_video_list(self, obj):
        video_qs = obj.videos.filter(state=obj.State.PUBLISHED).order_by("-published_date")
        if is_android_request():
            video_qs = video_qs.exclude(exclude_android=True)
        result = ChannelVideoSerializer(list(video_qs), many=True).data
        return result


class ChannelVideoCreatorSerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = VideoCreator
        fields = [
            'id',
            'name',
            'photo',
            'is_staff_choice',
        ]


class ChannelVideoSerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = Video
        fields = [
            'id',
            'title',
            'paid',
            'file',
            'style',
            'uid',
            'thumbnail',
            'trend_image',
            'height',
            'width',
            'caption',
            'liked_by_me',
            'likes_count',
            'is_trend',
            'is_favorite',
            'transcript',
            'quality_convert_job_finished',
            'short_trimmer_job_finished',
            'transcript_job_finished',
            'video_quality_status',
            'video_short_version_status',
            'transcript_status',
            'channels',
            'published_date',
            'creator',
        ] + PublisherSerializerMixin.FIELDS

    date_created = serializers.DateTimeField(read_only=True)
    style = serializers.SerializerMethodField()
    liked_by_me = serializers.SerializerMethodField()
    likes_count = serializers.SerializerMethodField()
    creator = ChannelVideoCreatorSerializer()

    def to_representation(self, instance):
        result = super().to_representation(instance)
        if result['thumbnail'] is None and instance.is_processes_done():
            result['thumbnail'] = instance.processed_files['first_frame']
        return result

    def get_liked_by_me(self, obj):
        if get_current_user() and hasattr(get_current_user(), 'profile'):
            return obj.liked_by.filter(id=get_current_user().profile.id).exists()
        return False

    def get_likes_count(self, obj):
        return obj.liked_by.count()

    def get_style(self, obj):
        return 'SHOWCASE_MEDIUM'


class VideoSerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = Video
        fields = [
            'id',
            'title',
            'paid',
            'file',
            'style',
            'uid',
            'thumbnail',
            'trend_image',
            'height',
            'width',
            'caption',
            'liked_by_me',
            'likes_count',
            'is_trend',
            'is_favorite',
            'transcript',
            'processed_files',
            'quality_convert_job_finished',
            'short_trimmer_job_finished',
            'transcript_job_finished',
            'video_quality_status',
            'video_short_version_status',
            'transcript_status',
            'channels',
            'published_date',
            'view_count_hour',
            'view_count_day',
            'view_count_total',
            'watch_count_total',
            'exclude_android',
            'creator',
        ] + PublisherSerializerMixin.FIELDS

    date_created = serializers.DateTimeField(read_only=True)
    style = serializers.SerializerMethodField()
    liked_by_me = serializers.SerializerMethodField()
    likes_count = serializers.SerializerMethodField()

    def to_representation(self, instance):
        result = super().to_representation(instance)
        if result['thumbnail'] is None and instance.is_processes_done():
            result['thumbnail'] = instance.processed_files['first_frame']
        return result

    def get_liked_by_me(self, obj):
        if get_current_user() and hasattr(get_current_user(), 'profile'):
            return obj.liked_by.filter(id=get_current_user().profile.id).exists()
        return False

    def get_likes_count(self, obj):
        return obj.liked_by.count()

    def get_style(self, obj):
        return 'SHOWCASE_MEDIUM'

    def create(self, validated_data):
        return super().create(validated_data)


class MediaUploadSerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = MediaUpload
        fields = ['id', 'name', 'file', 'image']


class VideoSharePageSerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = Video
        fields = ['id', 'title', 'paid', 'thumbnail', 'caption', 'short_video']


class VideoCreatorSerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = VideoCreator
        fields = [
            'id',
            'name',
            'photo',
            'bio',
            'is_staff_choice',
            'order',
            'date_created',
        ]
