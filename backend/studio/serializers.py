from rest_framework import serializers

from reusable.mixins.serializers import HttpsUrlsOnlySerializerMixin, RequestAddedSerializerMixin
from studio.models import Device, DeviceMotor, Beat, Rhythm, RhythmBeat


class BeatSerializer(HttpsUrlsOnlySerializerMixin, RequestAddedSerializerMixin, serializers.ModelSerializer):
    class Meta:
        model = Beat
        fields = ['id', 'title', 'device_motor', 'pre_pattern', 'color_hex', 'visual_draw', 'date_created']


class DeviceMotorSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeviceMotor
        fields = ['id', 'title', 'motor_id', 'beats', 'date_created']

    beats = BeatSerializer(many=True)


class DeviceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Device
        exclude = ('deleted_at',)


class RhythmBeatSerializer(serializers.ModelSerializer):
    class Meta:
        model = RhythmBeat
        fields = ['id', 'beat', 'start_time', 'end_time', 'intensity']

    beat = BeatSerializer()


class RhythmSerializer(serializers.ModelSerializer):
    class Meta:
        model = Rhythm
        fields = ['id', 'device', 'story', 'is_story_default', 'title', 'created_by', 'beats', 'date_created']

    beats = RhythmBeatSerializer(many=True, allow_null=True, required=False)
