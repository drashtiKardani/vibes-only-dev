from django_filters import rest_framework as filters

from . import models


class Video(filters.FilterSet):
    channel = filters.ModelChoiceFilter(
        queryset=models.Channel.objects.all(), method='filter_channel'
    )

    class Meta:
        model = models.Video
        fields = ('channel', 'state', 'creator')

    def filter_channel(self, queryset, name, value):
        if value:
            queryset = queryset.filter(channels=value)
        return queryset
