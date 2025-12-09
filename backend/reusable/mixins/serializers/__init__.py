from django.db import models
from crum import get_current_request
from rest_framework import serializers
from rest_framework.fields import FileField, ImageField, Field


class RequestAddedSerializerMixin:
    def __init__(self, *args, **kwargs) -> None:
        self: serializers.ModelSerializer
        super().__init__(*args, **kwargs)
        self._context['request'] = get_current_request()


class HttpsOnlyRepresentation:
    def to_representation(self, value):
        self: Field

        if not value:
            return None

        try:
            url = value.url
        except AttributeError:
            return None
        request = self.context.get('request', None)
        if request is not None:
            url = request.build_absolute_uri(url)
            if url.startswith('http://'):
                url = 'https' + url[4:]
        return url


class HttpsOnlyFileField(HttpsOnlyRepresentation, FileField):
    pass


class HttpsOnlyImageField(HttpsOnlyRepresentation, ImageField):
    pass


class HttpsUrlsOnlySerializerMixin:
    serializer_field_mapping = (
        serializers.ModelSerializer.serializer_field_mapping.copy()
    )
    serializer_field_mapping[models.FileField] = HttpsOnlyFileField
    serializer_field_mapping[models.ImageField] = HttpsOnlyImageField
