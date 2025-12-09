from crum import get_current_user
from rest_framework import serializers

from reusable.mixins.serializers import (
    RequestAddedSerializerMixin,
    HttpsUrlsOnlySerializerMixin,
)
from studio.serializers import RhythmSerializer
from stories.models import Character, Category, Story, Section, Home
from reusable.views import is_android_request
from reusable.mixins.serializers.models import PublisherSerializerMixin


class CharacterSerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = Character
        fields = [
            'id',
            'first_name',
            'last_name',
            'bio',
            'order',
            'profile_image',
            'stories_count',
            'show_on_homepage',
        ] + PublisherSerializerMixin.FIELDS

    date_created = serializers.DateTimeField(read_only=True)
    stories_count = serializers.SerializerMethodField()

    def get_stories_count(self, obj) -> int:
        return obj.stories.count()


class CategoryCompactSerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = Category
        fields = [
            'id',
            'title',
            'image',
            'android_image',
            'tile_view',
            'background_color',
            'related_categories',
            'stories_count',
        ]

    related_categories = serializers.SerializerMethodField()
    stories_count = serializers.SerializerMethodField()

    def get_stories_count(self, obj) -> int:
        return obj.stories.count()

    def get_related_categories(self, obj):
        return []


class CategoryExtendedSerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = Category
        fields = [
            'id',
            'title',
            'image',
            'android_image',
            'tile_view',
            'background_color',
            'related_categories',
            'related_characters',
            'stories_count',
            'published_date',
        ] + PublisherSerializerMixin.FIELDS

    date_created = serializers.DateTimeField(read_only=True)
    related_categories = CategoryCompactSerializer(many=True, required=False)
    related_characters = serializers.SerializerMethodField()
    stories_count = serializers.SerializerMethodField()

    def get_stories_count(self, obj) -> int:
        return obj.stories.count()

    def get_related_characters(self, obj):
        obj: Category
        return CharacterSerializer(
            Character.objects.filter(stories__categories=obj), many=True
        ).data


class CategorySerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = Category
        fields = [
            'id',
            'title',
            'image',
            'android_image',
            'tile_view',
            'background_color',
            'related_categories',
            'stories_count',
            'published_date',
        ] + PublisherSerializerMixin.FIELDS

    date_created = serializers.DateTimeField(read_only=True)
    related_categories = serializers.SerializerMethodField()
    stories_count = serializers.SerializerMethodField()

    def get_stories_count(self, obj) -> int:
        return obj.stories.count()

    def get_related_categories(self, obj):
        return []

    def to_representation(self, instance):
        data = super().to_representation(instance)
        if is_android_request() and instance.android_image:
            data['image'] = data['android_image']
        return data


class StoryCompactSerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = Story
        fields = [
            'id',
            'title',
            'description',
            'short_description',
            'paid',
            'image_cover',
            'image_full',
            'image_showcase_extended',
            'image_showcase_tall',
            'image_showcase_medium',
            'image_showcase_small',
            'audio',
            'audio_preview',
            'audio_length_seconds',
            'favorite_by_me',
            'published_date',
        ]

    favorite_by_me = serializers.SerializerMethodField()

    def get_favorite_by_me(self, obj):
        if get_current_user() and hasattr(get_current_user(), 'profile'):
            return obj.favorite_by.filter(id=get_current_user().profile.id).exists()
        return False


class CharacterExtendedSerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = Character
        fields = [
            'id',
            'first_name',
            'last_name',
            'bio',
            'order',
            'profile_image',
            'stories',
            'stories_count',
            'show_on_homepage',
        ] + PublisherSerializerMixin.FIELDS

    date_created = serializers.DateTimeField(read_only=True)
    stories = StoryCompactSerializer(many=True)
    stories_count = serializers.SerializerMethodField()

    def get_stories_count(self, obj) -> int:
        return obj.stories.count()


class StoryCreateSerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = Story
        fields = [
            'id',
            'title',
            'description',
            'short_description',
            'paid',
            'image_cover',
            'image_full',
            'image_showcase_extended',
            'image_showcase_tall',
            'image_showcase_medium',
            'image_showcase_small',
            'audio',
            'audio_preview',
            'characters',
            'categories',
            'new',
            'featured',
            'trending',
            'top_10',
            'staff_pick',
            'transcript',
            'published_date',
            'audio_length_seconds',
        ] + PublisherSerializerMixin.FIELDS

    date_created = serializers.DateTimeField(read_only=True)

    def to_representation(self, instance):
        result = super().to_representation(instance)
        result['channels'] = []
        return result


class StorySerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = Story
        fields = [
            'id',
            'title',
            'description',
            'short_description',
            'image_cover',
            'image_full',
            'image_showcase_extended',
            'image_showcase_tall',
            'image_showcase_medium',
            'image_showcase_small',
            'audio',
            'audio_preview',
            'transcript',
            'beat',
            'characters',
            'categories',
            'favorite_by_me',
            'new',
            'paid',
            'featured',
            'trending',
            'top_10',
            'staff_pick',
            'published_date',
            'audio_length_seconds',
        ] + PublisherSerializerMixin.FIELDS

    date_created = serializers.DateTimeField(read_only=True)
    characters = CharacterSerializer(many=True, required=False)
    categories = CategorySerializer(many=True, required=False)
    favorite_by_me = serializers.SerializerMethodField()

    def get_image_url(self, field):
        try:
            url = field.url
        except AttributeError:
            return None
        request = self.context.get('request', None)
        if request is not None:
            return request.build_absolute_uri(url).replace('http://', 'https://')
        return url

    def to_representation(self, instance):
        result = super().to_representation(instance)
        if result['image_full'] is None:
            result['image_full'] = result['image_cover']
        if result['image_showcase_extended'] is None:
            result['image_showcase_extended'] = result['image_cover']
        if result['image_showcase_tall'] is None:
            result['image_showcase_tall'] = result['image_cover']
        if result['image_showcase_medium'] is None:
            result['image_showcase_medium'] = result['image_cover']
        if result['image_showcase_small'] is None:
            result['image_showcase_small'] = result['image_cover']
        return result

    def get_favorite_by_me(self, obj):
        if get_current_user() and hasattr(get_current_user(), 'profile'):
            return obj.favorite_by.filter(id=get_current_user().profile.id).exists()
        return False


class StoryExtendedSerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = Story
        fields = [
            'id',
            'uid',
            'title',
            'description',
            'short_description',
            'image_cover',
            'image_full',
            'image_showcase_extended',
            'image_showcase_tall',
            'image_showcase_medium',
            'image_showcase_small',
            'audio',
            'audio_preview',
            'transcript',
            'beat',
            'characters',
            'categories',
            'favorite_by_me',
            'related_stories',
            'rhythms',
            'new',
            'paid',
            'featured',
            'trending',
            'top_10',
            'staff_pick',
            'published_date',
            'studio_link',
            'audio_length_seconds',
            'view_count_hour',
            'view_count_day',
            'view_count_total',
        ] + PublisherSerializerMixin.FIELDS

    date_created = serializers.DateTimeField(read_only=True)
    characters = CharacterSerializer(many=True, required=False)
    categories = CategorySerializer(many=True, required=False)
    favorite_by_me = serializers.SerializerMethodField()
    related_stories = serializers.SerializerMethodField()
    rhythms = RhythmSerializer(many=True)

    def get_image_url(self, field):
        try:
            url = field.url
        except AttributeError:
            return None
        request = self.context.get('request', None)
        if request is not None:
            return request.build_absolute_uri(url).replace('http://', 'https://')
        return url

    def to_representation(self, instance):
        result = super().to_representation(instance)
        result['channels'] = []
        return result

    def get_related_stories(self, obj):
        return StoryCompactSerializer(
            Story.objects.filter(categories__in=obj.categories.all()).order_by('?')[
                :10
            ],
            many=True,
        ).data

    def get_favorite_by_me(self, obj):
        if get_current_user() and hasattr(get_current_user(), 'profile'):
            return obj.favorite_by.filter(id=get_current_user().profile.id).exists()
        return False


class StoryStudioSerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = Story
        fields = ['title', 'uid', 'audio', 'transcript', 'rhythms']

    rhythms = RhythmSerializer(many=True)


class SectionCompactSerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = Section
        fields = ['id', 'title', 'content_type', 'style']


class SectionSerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = Section
        fields = ['id', 'title', 'content_type', 'style', 'stories']

    def to_representation(self, instance):
        result = super().to_representation(instance)
        state = self.context['state']
        result['containing_stories'] = StorySerializer(
            instance.containing_stories(state), many=True
        ).data
        result['characters'] = CharacterSerializer(
            instance.characters(state), many=True
        ).data
        result['categories'] = CategorySerializer(
            instance.categories(state), many=True
        ).data
        return result


class HomeCreateSerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = Home
        fields = [
            'id',
            'title',
            'sections',
            'sections_count',
        ] + PublisherSerializerMixin.FIELDS

    date_created = serializers.DateTimeField(read_only=True)
    sections_count = serializers.ReadOnlyField(source='sections.count')


class HomeSerializer(
    HttpsUrlsOnlySerializerMixin,
    RequestAddedSerializerMixin,
    serializers.ModelSerializer,
):
    class Meta:
        model = Home
        fields = ['id', 'title', 'sections', 'sections_count']

    def to_representation(self, instance):
        result = super().to_representation(instance)
        result['sections'] = SectionSerializer(
            instance.sections.all(), many=True, context=self.context
        ).data
        return result

    sections_count = serializers.ReadOnlyField(source='sections.count')


class StoryStudioSerializer(serializers.ModelSerializer):
    # FIXME: duplicate class definition
    class Meta:
        model = Story
        fields = ('uid', 'title', 'beat', 'transcript', 'audio')
        read_only_fields = ('title', 'uid', 'transcript', 'audio')
