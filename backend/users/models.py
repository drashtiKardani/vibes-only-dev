import logging
from random import sample

from django.core.exceptions import ValidationError
from datetime import timedelta
from django.utils import timezone
from django.db import models
from django.dispatch import receiver
from django.db.models.signals import post_delete

from . import tasks, utils
from hippo_shield.models import User
from reusable.models import BaseModel


logger = logging.getLogger(__name__)


class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    first_name = models.CharField(max_length=255, blank=True, null=True)
    last_name = models.CharField(max_length=255, blank=True, null=True)
    profile_image = models.ImageField(
        upload_to=utils.profile_image_path, blank=True, null=True
    )
    two_fa_code = models.CharField(max_length=6, blank=True, null=True, unique=True)

    @property
    def is_staff(self):
        try:
            self.staff
        except Staff.DoesNotExist:
            return False
        return True

    @property
    def get_email(self):
        return self.user.email_password_authentication.email

    def set_login_code(self):
        try_counter = 0
        chars = '0123456789'
        while True:
            try:
                try_counter += 1
                if try_counter > 10:
                    break
                self.two_fa_code = ''.join(sample(chars, 6))
                expire_time = timezone.localtime() + timezone.timedelta(seconds=60)
                self.save()
                tasks.delete_2fa_code.apply_async((self.staff.pk,), eta=expire_time)
            except:
                continue
            break

    def send_login_code(self):
        text_body = f'Your Vibes Only Login Code: {self.two_fa_code}'
        tasks.send_sms.delay(
            from_phone="+16072703928", to=self.staff.phone_number, body=text_body
        )

    def __str__(self):
        if self.first_name or self.last_name:
            return f'{self.first_name} {self.last_name}'.strip()
        return str(self.user)


class Staff(Profile):
    class Meta:
        permissions = [('simulator', 'Simulator'), ('publisher', 'Publisher')]

    phone_number = models.CharField(max_length=255, blank=True, null=True)


@receiver(post_delete, sender=Staff)
def post_delete_user(sender, instance, *args, **kwargs):
    if instance.user:
        instance.user.delete()


class PushMessage(BaseModel):
    class Target(models.TextChoices):
        ALL = ('all', 'All')
        FREE = ('free', 'Free')
        PAID = ('paid', 'Paid')

    class Status(models.TextChoices):
        SCHEDULED = ("scheduled", "Scheduled")
        SENDING = ("sending", "Sending")
        SENT = ("sent", "Sent")
        FAILED = ("failed", "Failed")

    title = models.CharField(max_length=255)
    body = models.TextField()
    data = models.JSONField(null=True)
    target = models.CharField(
        max_length=31,
        choices=Target.choices,
        default=Target.ALL
    )
    status = models.CharField(
        max_length=15,
        choices=Status.choices,
        blank=True,
    )
    scheduled_for = models.DateTimeField(null=True, blank=True)
    task_id = models.UUIDField(null=True, blank=True, editable=False)
    result = models.TextField(null=True)
    fcm_message_id = models.CharField(max_length=255, null=True)

    @property
    def fcm_topic(self):
        if self.target == self.Target.FREE:
            return 'free'
        elif self.target == self.Target.PAID:
            return 'paid'
        return None

    @property
    def fcm_all_target_condition(self):
        return "'free' in topics || 'paid' in topics"

    def save(self, *args, **kwargs):
        created = self.pk is None
        if created:
            now = timezone.now()
            if not self.scheduled_for:
                self.scheduled_for = now
            else:
                if self.scheduled_for < now - timedelta(minutes=1):
                    raise ValidationError("Scheduled time can not be in the past")
            self.status = self.Status.SCHEDULED
        super().save(*args, **kwargs)
