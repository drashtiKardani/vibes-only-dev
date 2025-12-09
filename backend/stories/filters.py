from django_filters import rest_framework as filters

from . import models


class Story(filters.FilterSet):
    category = filters.ModelChoiceFilter(
        queryset=models.Category.objects.all(), method='filter_category'
    )
    character = filters.ModelChoiceFilter(
        queryset=models.Character.objects.all(), method='filter_character'
    )

    class Meta:
        model = models.Story
        fields = ('state', 'category', 'character')

    def filter_category(self, queryset, name, value):
        if value:
            queryset = queryset.filter(categories=value)
        return queryset

    def filter_character(self, queryset, name, value):
        if value:
            queryset = queryset.filter(characters=value)
        return queryset


class Character(filters.FilterSet):
    class Meta:
        model = models.Character
        fields = ('state',)
