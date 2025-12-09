import uuid
from django.db import models
from django.utils import timezone


from reusable.models import BaseModel
from .integrations.apple import appstore
from .integrations.google import playstore


class Subscription(BaseModel):
    class AppPlatform(models.TextChoices):
        IOS = 'IOS', 'iOS'
        ANDROID = 'ANDROID', 'Android'

    token = models.CharField(max_length=40480)
    subscription_id = models.CharField(max_length=30)
    device_id = models.CharField(max_length=30, unique=True)
    app_platform = models.CharField(
        max_length=8,
        choices=AppPlatform.choices,
        null=True,
        blank=True,
    )

    @property
    def exp_date(self):
        if self.subscription_id == 'monthly_billing':
            return self.created_at + timezone.timedelta(days=30)
        return self.created_at + timezone.timedelta(days=365)

    @property
    def package(self):
        if self.subscription_id == 'monthly_billing':
            return 'Monthly'
        return 'Yearly'

    @property
    def price(self):
        if self.subscription_id == 'monthly_billing':
            return 7.99
        elif self.subscription_id == 'annual_billing':
            return 49.99
        return None

    @property
    def is_valid(self):
        if not self.token:
            return False

        is_unknown_platform = self.app_platform not in self.AppPlatform.values

        if is_unknown_platform or self.app_platform == self.AppPlatform.IOS:
            result = appstore.validate_apple_token(self.token)
            if result.valid:
                return True
        elif is_unknown_platform or self.app_platform == self.AppPlatform.ANDROID:
            result = playstore.validate_google_token(
                self.token,
                self.subscription_id
            )
            if result.valid:
                return True

        return False

    def __str__(self):
        return f"{self.pk} ({self.app_platform or 'Unknown'})"


class Promotion(BaseModel):
    class Target(models.TextChoices):
        FREE = ('free', 'Free')
        PAID = ('paid', 'Paid')

    class SubscriptionType(models.TextChoices):
        MONTHLY = ('monthly_billing', 'Monthly')
        ANNUAL = ('annual_billing', 'Annual')

    class Constraint(models.TextChoices):
        EQUALS = ('equals', 'Equals')
        LESS_THAN = ('less_than', 'Less Than')
        MORE_THAN = ('more_than', 'More Than')

    uid = models.UUIDField(default=uuid.uuid4)
    title = models.CharField(max_length=256)
    body = models.TextField(blank=True)
    code = models.CharField(max_length=4096)
    target = models.CharField(
        max_length=32,
        choices=Target.choices,
    )
    subscription_type = models.CharField(
        max_length=32,
        null=True,
        blank=True,
        choices=SubscriptionType.choices,
    )
    frequency = models.PositiveIntegerField(
        default=1,
        help_text="Number of times to show this promotion",
    )
    days_since_membership_start = models.PositiveIntegerField(
        null=True,
        blank=True,
    )
    days_since_membership_start_constraint = models.CharField(
        max_length=32,
        choices=Constraint.choices,
        default=Constraint.MORE_THAN,
    )
    days_since_registration = models.PositiveIntegerField(
        null=True,
        blank=True,
    )
    days_since_registration_constraint = models.CharField(
        max_length=32,
        choices=Constraint.choices,
        default=Constraint.MORE_THAN,
    )
    days_until_subscription_end = models.PositiveIntegerField(
        null=True,
        blank=True,
    )
    days_until_subscription_end_constraint = models.CharField(
        max_length=32,
        choices=Constraint.choices,
        default=Constraint.MORE_THAN,
    )
    visit_count = models.PositiveBigIntegerField(default=0)
    usage_count = models.PositiveBigIntegerField(default=0)

    class Meta:
        ordering = (
            "-created_at",
            "id",
        )

    def __str__(self):
        return f"{self.pk} - {self.title}"
