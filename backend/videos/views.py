from django.db.models import F, Count
from django.http.request import QueryDict
from django.utils.decorators import method_decorator
from django.views.decorators.cache import cache_page
from rest_framework.decorators import action
from rest_framework.exceptions import NotAcceptable
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet
from rest_framework.permissions import IsAuthenticatedOrReadOnly, AllowAny
from rest_framework.filters import OrderingFilter
from django_filters.rest_framework import DjangoFilterBackend

from . import filters, serializers, models
from reusable.views import is_application_request, is_android_request


class ChannelViewSet(ModelViewSet):
    ordering_fields = ['state', 'published_date']
    permission_classes = (IsAuthenticatedOrReadOnly,)

    def get_queryset(self):
        queryset = models.Channel.objects.all()
        if is_application_request():
            queryset = queryset.annotate(videos_count=Count('videos')).filter(
                videos_count__gt=0
            )
            if is_android_request():
                queryset = queryset.exclude(title__iexact='vibes tutorials')

        return queryset.order_by(
            F('order'),
            F('published_date').desc(nulls_last=True),
            '-id'
        )

    def get_serializer_class(self):
        if 'state' in self.request.GET and self.request.GET['state'] == 'published':
            return serializers.PublishedChannelSerializer
        return serializers.ChannelSerializer

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


# @method_decorator([cache_page(60)], name='dispatch')
class VideoViewSet(ModelViewSet):
    permission_classes = (IsAuthenticatedOrReadOnly,)
    filterset_class = filters.Video
    serializer_class = serializers.VideoSerializer
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
        result = models.Video.objects.prefetch_related('channels').all()
        if is_application_request():
            result = result.filter(file__isnull=False).exclude(
                state=models.Video.State.CREATED
            )
        if is_android_request():
            result = result.exclude(exclude_android=True)
        return result.order_by('-published_date')

    def create(self, request):
        if type(request.data) is QueryDict:
            request.data._mutable = True
        return super().create(request)

    @action(detail=True, methods=['get'])
    def like(self, request, pk=None):
        video = self.get_object()
        video.liked_by.add(self.request.user.profile)
        return Response(self.get_serializer(self.get_object()).data)

    @action(detail=True, methods=['get'])
    def unlike(self, request, pk=None):
        video = self.get_object()
        video.liked_by.remove(self.request.user.profile)
        return Response(self.get_serializer(self.get_object()).data)

    @action(detail=True, methods=['get'])
    def share_page(self, request, pk=None):
        video = self.get_object()
        return Response(serializers.VideoSharePageSerializer(video).data)

    @action(detail=True, methods=['post'], permission_classes=[AllowAny])
    def watched(self, request, pk=None):
        if not is_application_request():
            raise NotAcceptable()

        updated_count = models.Video.objects.filter(
            pk=pk,
        ).update(
            watch_count_total=F("watch_count_total") + 1,
        )
        status = "Success" if updated_count == 1 else "Failed"

        return Response({"status": status})


class MediaUploadViewSet(ModelViewSet):
    model = models.MediaUpload
    permission_classes = (IsAuthenticatedOrReadOnly,)


class VideoCreatorViewSet(ModelViewSet):
    queryset = models.VideoCreator.objects.all()
    permission_classes = [IsAuthenticatedOrReadOnly,]
    serializer_class = serializers.VideoCreatorSerializer
    filter_backends = [DjangoFilterBackend, OrderingFilter]
    filterset_fields = ['is_staff_choice']
    ordering_fields = ['id', 'order']
