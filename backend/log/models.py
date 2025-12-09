from django.db import models

from reusable.models import BaseModel


class TwilioLog(BaseModel):
    from_number = models.CharField(max_length=15, null=True)
    to = models.CharField(max_length=15, null=True)
    body = models.TextField(null=True)
    status_data = models.JSONField(null=True, blank=True)
    send_data = models.JSONField(null=True, blank=True)

    def __str__(self):
        return f"({self.from_number} - {self.to})"


class AWSLog(BaseModel):
    TRANSCRIBE = "transcribe"
    MEDIACONVERT = "mediaconvert"
    SOURCE_CHOICES = ((TRANSCRIBE, TRANSCRIBE), (MEDIACONVERT, MEDIACONVERT))
    source = models.CharField(
        choices=SOURCE_CHOICES, max_length=20, null=True, blank=True
    )
    source = models.CharField(max_length=30, null=True, blank=True)
    text = models.TextField(null=True, blank=True)
    request = models.JSONField(null=True, blank=True)
    video = models.ForeignKey(
        "videos.Video", on_delete=models.SET_NULL, null=True, blank=True
    )
    status = models.CharField(max_length=30, null=True, blank=True)

    def __str__(self):
        return f"({self.pk} - {self.source})"
