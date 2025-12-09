from django.views.decorators.cache import cache_page
from django.utils.decorators import method_decorator
from django.db.models import F, Case, When, Value, FloatField
from django.contrib.postgres.search import SearchQuery, SearchVector, SearchRank
from rest_framework import filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet
from rest_framework.exceptions import PermissionDenied
from rest_framework.filters import SearchFilter, OrderingFilter
from rest_framework.permissions import IsAuthenticatedOrReadOnly
from django_filters.rest_framework import DjangoFilterBackend

from . import serializers, models
from . import filters as sto_filters
from videos import models as vid_models
from videos import serializers as vid_serializers
from reusable.views import is_application_request


class CharacterViewSet(ModelViewSet):
    permission_classes = (IsAuthenticatedOrReadOnly,)
    ordering_fields = ['first_name', 'state', 'order']
    ordering = ['order', 'id']
    filterset_class = sto_filters.Character

    def get_queryset(self):
        qs = models.Character.objects.all()
        if self.request.user.is_anonymous:
            qs = qs.filter(show_on_homepage=True)
        return qs.order_by('first_name')

    def get_serializer_class(self):
        if self.action == 'retrieve':
            return serializers.CharacterExtendedSerializer
        return serializers.CharacterSerializer


class CategoryViewSet(ModelViewSet):
    queryset = models.Category.objects.order_by(
        F('published_date').desc(nulls_last=True),
        '-id'
    )
    filter_backends = (DjangoFilterBackend, SearchFilter, OrderingFilter)
    ordering_fields = ['title', 'state']

    def get_serializer_class(self):
        if self.action == 'retrieve':
            return serializers.CategoryExtendedSerializer
        return serializers.CategorySerializer


@method_decorator([cache_page(60)], name='dispatch')
class StoryViewSet(ModelViewSet):
    permission_classes = (IsAuthenticatedOrReadOnly,)
    filterset_class = sto_filters.Story
    filter_backends = [
        filters.SearchFilter,
        filters.OrderingFilter,
        DjangoFilterBackend,
    ]
    search_fields = ["title"]
    ordering_fields = [
        'title',
        'published_date',
        'date_created',
        'state',
        'view_count_hour',
        'view_count_day',
        'view_count_total',
    ]

    def get_queryset(self):
        qs = models.Story.objects.prefetch_related('categories', 'characters').all()
        if is_application_request():
            qs = qs.filter(image_cover__isnull=False)

        has_character_filter = bool(self.request.query_params.get('character'))
        ordering = F('published_date')
        return qs.order_by(
            ordering.desc(nulls_last=True) if not has_character_filter
            else ordering.asc(nulls_last=True)
        )

    def get_serializer_class(self):
        if self.action in ['create', 'update', 'partial_update']:
            return serializers.StoryCreateSerializer
        return serializers.StoryExtendedSerializer

    @action(detail=True, methods=['get'])
    def studio(self, request, pk=None):
        return Response(serializers.StoryStudioSerializer(self.get_object()).data)

    @action(detail=True, methods=['get'])
    def favorite(self, request, pk=None):
        selected = self.get_object()
        selected.favorite_by.add(self.request.user.profile)
        return Response(self.get_serializer(self.get_object()).data)

    @action(detail=True, methods=['get'])
    def unfavorite(self, request, pk=None):
        selected = self.get_object()
        selected.favorite_by.remove(self.request.user.profile)
        return Response(self.get_serializer(self.get_object()).data)

    @action(detail=True, methods=['delete'])
    def delete_vibe(self, request, pk=None):
        story = self.get_object()
        story.beat = None
        story.save()
        return Response(self.get_serializer(story).data)


class StoryStudioViewSet(ModelViewSet):
    queryset = models.Story.objects.all()
    serializer_class = serializers.StoryStudioSerializer
    lookup_field = 'uid'

    def create(self, request):
        raise PermissionDenied(detail="creation not accepted")

    def destroy(self, request, pk):
        raise PermissionDenied(detail="destortion not accepted")

    def list(self, request):
        raise PermissionDenied(detail="listing not accepted")


class SectionViewSet(ModelViewSet):
    queryset = models.Section.objects.order_by("-id")
    serializer_class = serializers.SectionSerializer
    ordering_fields = ['state']


class HomeViewSet(ModelViewSet):
    permission_classes = (IsAuthenticatedOrReadOnly,)

    def get_serializer_class(self):
        if self.action in ['create', 'update', 'partial_update']:
            return serializers.HomeCreateSerializer
        return serializers.HomeSerializer

    @action(detail=False, methods=['get'])
    def active_home(self, request, format=None):
        state = request.query_params.get('state')
        home = models.Home.objects.get(id=1)
        return Response(serializers.HomeSerializer(home, context={'state': state}).data)

    @action(detail=False, methods=['get'])
    def global_search(self, request, format=None):
        query_param = self.request.query_params.get(
            'key', default=False
        ) or self.request.query_params.get('q', default="")
        last = query_param.split()[-1] if len(query_param.split()) > 0 else None
        query = SearchQuery(query_param)
        stories_vector = (
            SearchVector('title', weight='A')
            + SearchVector('short_description', weight='B')
            + SearchVector('description', weight='C')
        )
        videos_vector = SearchVector('title', weight='A')
        categories_vector = SearchVector('title', weight='A')
        channels_vector = SearchVector('title', weight='A') + SearchVector(
            'description', weight='B'
        )
        characters_vector = SearchVector('first_name', 'last_name', weight='A')
        stories = models.Story.objects.all()
        videos = vid_models.Video.objects.all()
        categories = models.Category.objects.all()
        channels = vid_models.Channel.objects.all()
        characters = models.Character.objects.all()
        if 'state' in self.request.GET and self.request.GET['state'] == 'published':
            stories = stories.filter(state='published')
            videos = videos.filter(state='published')
            categories = categories.filter(state='published')
            channels = channels.filter(state='published')
            characters = characters.filter(state='published')
        if last:
            stories = stories.annotate(
                rankb=Case(
                    When(title__icontains=last, then=Value(0.4)),
                    default=Value(0),
                    output_field=FloatField(),
                )
            )
            stories = stories.annotate(
                rankc=Case(
                    When(short_description__icontains=last, then=Value(0.2)),
                    default=Value(0),
                    output_field=FloatField(),
                )
            )
            stories = stories.annotate(
                rankd=Case(
                    When(description__icontains=last, then=Value(0.1)),
                    default=Value(0),
                    output_field=FloatField(),
                )
            )
            videos = videos.annotate(
                rankb=Case(
                    When(title__icontains=last, then=Value(0.4)),
                    default=Value(0),
                    output_field=FloatField(),
                )
            )
            categories = categories.annotate(
                rankb=Case(
                    When(title__icontains=last, then=Value(0.4)),
                    default=Value(0),
                    output_field=FloatField(),
                )
            )
            channels = channels.annotate(
                rankb=Case(
                    When(title__icontains=last, then=Value(0.4)),
                    default=Value(0),
                    output_field=FloatField(),
                )
            )
            channels = channels.annotate(
                rankc=Case(
                    When(description__icontains=last, then=Value(0.2)),
                    default=Value(0),
                    output_field=FloatField(),
                )
            )
            characters = characters.annotate(
                rankb=Case(
                    When(first_name__icontains=last, then=Value(0.4)),
                    default=Value(0),
                    output_field=FloatField(),
                )
            )
            characters = characters.annotate(
                rankc=Case(
                    When(last_name__icontains=last, then=Value(0.2)),
                    default=Value(0),
                    output_field=FloatField(),
                )
            )

        stories = (
            stories.annotate(ranka=SearchRank(stories_vector, query))
            .annotate(rank=F('ranka') + F('rankb') + F('rankc') + F('rankd'))
            .filter(rank__gte=0.1)
            .order_by('-ranka')
        )
        videos = (
            videos.annotate(ranka=SearchRank(videos_vector, query))
            .annotate(rank=F('ranka') + F('rankb'))
            .filter(rank__gte=0.1)
            .order_by('-ranka')
        )
        categories = (
            categories.annotate(ranka=SearchRank(categories_vector, query))
            .annotate(rank=F('ranka') + F('rankb'))
            .filter(rank__gte=0.1)
            .order_by('-ranka')
        )
        channels = (
            channels.annotate(ranka=SearchRank(channels_vector, query))
            .annotate(rank=F('ranka') + F('rankb') + F('rankc'))
            .filter(rank__gte=0.1)
            .order_by('-ranka')
        )
        characters = (
            characters.annotate(ranka=SearchRank(characters_vector, query))
            .annotate(rank=F('ranka') + F('rankb') + F('rankc'))
            .filter(rank__gte=0.1)
            .order_by('-ranka')
        )
        found_objects = (
            [
                {
                    'character': None,
                    'category': None,
                    'story': serializers.StorySerializer(item).data,
                    'channel': None,
                    'video': None,
                    'rank': item.rank,
                    'ranka': getattr(item, 'ranka', None),
                    'rankb': getattr(item, 'rankb', None),
                    'rankc': getattr(item, 'rankc', None),
                    'rankd': getattr(item, 'rankd', None),
                }
                for item in stories
            ]
            + [
                {
                    'character': None,
                    'category': None,
                    'story': None,
                    'channel': None,
                    'video': vid_serializers.ChannelVideoSerializer(item).data,
                    'rank': item.rank,
                    'ranka': getattr(item, 'ranka', None),
                    'rankb': getattr(item, 'rankb', None),
                    'rankc': getattr(item, 'rankc', None),
                    'rankd': getattr(item, 'rankd', None),
                }
                for item in videos
            ]
            + [
                {
                    'character': None,
                    'category': serializers.CategorySerializer(item).data,
                    'story': None,
                    'channel': None,
                    'video': None,
                    'rank': item.rank,
                    'ranka': getattr(item, 'ranka', None),
                    'rankb': getattr(item, 'rankb', None),
                    'rankc': getattr(item, 'rankc', None),
                    'rankd': getattr(item, 'rankd', None),
                }
                for item in categories
            ]
            + [
                {
                    'character': None,
                    'category': None,
                    'story': None,
                    'channel': vid_serializers.ChannelSerializer(item).data,
                    'video': None,
                    'rank': item.rank,
                    'ranka': getattr(item, 'ranka', None),
                    'rankb': getattr(item, 'rankb', None),
                    'rankc': getattr(item, 'rankc', None),
                    'rankd': getattr(item, 'rankd', None),
                }
                for item in channels
            ]
            + [
                {
                    'character': serializers.CharacterSerializer(item).data,
                    'category': None,
                    'story': None,
                    'channel': None,
                    'video': None,
                    'rank': item.rank,
                    'ranka': getattr(item, 'ranka', None),
                    'rankb': getattr(item, 'rankb', None),
                    'rankc': getattr(item, 'rankc', None),
                    'rankd': getattr(item, 'rankd', None),
                }
                for item in characters
            ]
        )
        results = sorted(found_objects, key=lambda item: item['rank'], reverse=True)
        return Response(results)

    @action(detail=False, methods=['get'])
    def studio_search(self, request, format=None):
        query_param = self.request.query_params.get(
            'key', default=False
        ) or self.request.query_params.get('q', default="")
        last = (
            query_param.split()[-1] if len(query_param.split()) > 0 else None
        )  # todo but why?

        query = SearchQuery(query_param)
        # todo is searching in generated transcript is a good idea?
        stories_vector = (
            SearchVector('title', weight='A')
            + SearchVector('short_description', weight='B')
            + SearchVector('description', weight='C')
        )

        stories = models.Story.objects.all()
        if last:
            stories = stories.annotate(
                rankb=Case(
                    When(title__icontains=last, then=Value(0.4)),
                    default=Value(0),
                    output_field=FloatField(),
                )
            )
            stories = stories.annotate(
                rankc=Case(
                    When(short_description__icontains=last, then=Value(0.2)),
                    default=Value(0),
                    output_field=FloatField(),
                )
            )
            stories = stories.annotate(
                rankd=Case(
                    When(description__icontains=last, then=Value(0.1)),
                    default=Value(0),
                    output_field=FloatField(),
                )
            )

        stories = (
            stories.annotate(ranka=SearchRank(stories_vector, query))
            .annotate(rank=F('ranka') + F('rankb') + F('rankc') + F('rankd'))
            .filter(rank__gte=0.1)
            .order_by('-ranka')
        )
        found_objects = [
            {
                'story': serializers.StoryStudioSerializer(item).data,
                'rank': item.rank,
                'ranka': getattr(item, 'ranka', None),
                'rankb': getattr(item, 'rankb', None),
                'rankc': getattr(item, 'rankc', None),
                'rankd': getattr(item, 'rankd', None),
            }
            for item in stories
        ]
        results = sorted(found_objects, key=lambda item: item['rank'], reverse=True)
        return Response(results)
