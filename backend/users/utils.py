from os import path
from django.utils import timezone
from django.core.exceptions import ValidationError

IMAGE_FILE_TYPES = ["jpeg", "jpg", "png", "bmp"]


def is_image(ext):
    if ext.lower() not in IMAGE_FILE_TYPES:
        raise ValidationError("unknown file format")
    return True


def profile_image_path(instance, filename):
    ext = filename.split(".")[-1].lower()
    if is_image(ext):
        return path.join(
            ".",
            "users",
            "profile",
            "image",
            f"{int(timezone.now().timestamp())}.{ext}",
        )
