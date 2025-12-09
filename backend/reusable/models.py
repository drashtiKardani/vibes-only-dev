import logging
import requests
from PIL import Image
from io import BytesIO
from django.db import models

MAX_SIZE = 600

logger = logging.getLogger(__name__)


def new_resized_image(image_url):
    content = BytesIO(requests.get(image_url).content)
    image = Image.open(content)
    width, height = image.width, image.height
    aspect_ratio = width / float(height)
    if width > MAX_SIZE and height > MAX_SIZE:
        new_width, new_height = MAX_SIZE, MAX_SIZE
    elif width > MAX_SIZE:
        new_width = MAX_SIZE
        new_height = int(aspect_ratio * new_width)
    elif height > MAX_SIZE:
        new_height = MAX_SIZE
        new_width = int(aspect_ratio * new_height)
    else:
        return False, None
    new_img = (new_width, new_height)
    image.thumbnail(new_img)
    img_temp = BytesIO()
    image.save(img_temp, 'png')
    return True, img_temp


class BaseModel(models.Model):
    created_at = models.DateTimeField(auto_now_add=True, null=True)
    updated_at = models.DateTimeField(auto_now=True)
    deleted_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        abstract = True
