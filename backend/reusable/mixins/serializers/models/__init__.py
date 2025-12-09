from rest_framework import serializers


class PublisherSerializerMixin:
    FIELDS = ['date_created', 'state']

    date_created = serializers.DateTimeField(read_only=True)
