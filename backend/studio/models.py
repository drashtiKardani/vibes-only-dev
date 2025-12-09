from django.db import models

from reusable.models import BaseModel
from stories.models import Story
from users.models import Staff


class Device(BaseModel):
    name = models.CharField(max_length=255)
    bluetooth_name = models.CharField(max_length=255, blank=True)
    shop_url = models.URLField(blank=True)
    number_of_motors = models.PositiveIntegerField(null=True)
    motor_name1 = models.TextField(blank=True)
    motor_name2 = models.TextField(blank=True)
    is_toy = models.BooleanField(default=False)
    shop_picture = models.ImageField(upload_to="studio/devices/", null=True, blank=True)
    controller_page_picture = models.ImageField(upload_to="studio/devices/", null=True, blank=True)
    ordering = models.PositiveIntegerField(default=0)

    class Meta:
        ordering = (
            "ordering",
            "-created_at",
        )

    def __str__(self):
        return f"{self.pk} - {self.name}"


class DeviceMotor(models.Model):
    motor_id = models.CharField(max_length=255, blank=True, null=True)
    title = models.CharField(max_length=255)
    date_created = models.DateTimeField(auto_now_add=True)

    @classmethod
    def get_default_serializer(cls):
        from studio.serializers import DeviceMotorSerializer

        return DeviceMotorSerializer

    def __str__(self):
        return f"{self.device} - {self.title}"


class Beat(models.Model):
    device_motor = models.ForeignKey(
        DeviceMotor, on_delete=models.CASCADE, related_name="beats"
    )
    title = models.CharField(max_length=255)
    color_hex = models.CharField(max_length=255, default="#7F00FF", blank=True)
    visual_draw = models.FileField(null=True, blank=True)
    pre_pattern = models.CharField(max_length=255, blank=True, null=True)
    date_created = models.DateTimeField(auto_now_add=True)

    @classmethod
    def get_default_serializer(cls):
        from studio.serializers import BeatSerializer

        return BeatSerializer

    def __str__(self):
        return f"{self.device_motor} - {self.title}"


class Rhythm(models.Model):
    device = models.ForeignKey(Device, on_delete=models.CASCADE, related_name="rhythms")
    story = models.ForeignKey(Story, on_delete=models.CASCADE, related_name="rhythms")
    is_story_default = models.BooleanField(default=False)
    title = models.CharField(max_length=255, blank=True, null=True)
    created_by = models.ForeignKey(
        Staff, on_delete=models.SET_NULL, null=True, blank=True
    )
    date_created = models.DateTimeField(auto_now_add=True)

    @classmethod
    def get_default_serializer(cls):
        from studio.serializers import RhythmSerializer

        return RhythmSerializer

    def __str__(self):
        return f"({self.device} - {self.story}) - {self.title}"


class RhythmBeat(models.Model):
    rhythm = models.ForeignKey(Rhythm, on_delete=models.CASCADE, related_name="beats")
    beat = models.ForeignKey(Beat, on_delete=models.CASCADE)
    start_time = models.TimeField()
    end_time = models.TimeField()
    intensity = models.IntegerField()

    @classmethod
    def get_default_serializer(cls):
        from studio.serializers import RhythmBeatSerializer

        return RhythmBeatSerializer

    def __str__(self):
        return f"{self.rhythm} - {self.id}"
