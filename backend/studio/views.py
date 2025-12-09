from rest_framework import status
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet
from rest_framework.permissions import IsAuthenticatedOrReadOnly

from . import serializers
from studio.models import Device, Beat, Rhythm, RhythmBeat


class DeviceViewSet(ModelViewSet):
    permission_classes = (IsAuthenticatedOrReadOnly,)
    queryset = Device.objects.filter(deleted_at=None)
    serializer_class = serializers.DeviceSerializer
    ordering_fields = ("id", "name", "created_at")
    ordering = ("ordering", "-created_at", "id")


class BeatViewSet(ModelViewSet):
    model = Beat


class RhythmViewSet(ModelViewSet):
    model = Rhythm

    def create(self, request, *args, **kwargs):
        data = request.data
        beats = data.pop('beats')
        serializer = self.get_serializer(data=data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        instance = serializer.instance
        for item in beats:
            RhythmBeat.objects.create(
                rhythm=instance,
                beat=Beat.objects.get(id=item['beat_id']),
                start_time=item['start_time'],
                end_time=item['end_time'],
                intensity=item['intensity'],
            )
        headers = self.get_success_headers(serializer.data)
        return Response(
            self.get_serializer(instance).data,
            status=status.HTTP_201_CREATED,
            headers=headers,
        )

    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        data = request.data
        beats = data.pop('beats')
        serializer = self.get_serializer(instance, data=data, partial=partial)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        instance.beats.all().delete()
        instance = serializer.instance
        for item in beats:
            RhythmBeat.objects.create(
                rhythm=instance,
                beat=Beat.objects.get(id=item['beat_id']),
                start_time=item['start_time'],
                end_time=item['end_time'],
                intensity=item['intensity'],
            )

        if getattr(instance, '_prefetched_objects_cache', None):
            # If 'prefetch_related' has been applied to a queryset, we need to
            # forcibly invalidate the prefetch cache on the instance.
            instance._prefetched_objects_cache = {}

        return Response(self.get_serializer(instance).data)
