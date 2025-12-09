from django.db.models import F, Case, When, ExpressionWrapper, IntegerField
from django.db.models.functions import ExtractDay
from django.contrib.postgres.functions import TransactionNow
from celery import Task
from celery.utils.log import get_task_logger

from vibes_only_backend.celery_settings import app

from .models import Subscription
from .integrations import revenuecat


logger = get_task_logger(__name__)


class BaseTaskWithRetry(Task):
    autoretry_for = (Exception,)
    retry_kwargs = {"max_retries": 10}
    retry_backoff = 5


class BaseValidationTaskWithRetry(BaseTaskWithRetry):
    autoretry_for = (Exception,)
    retry_kwargs = {"max_retries": 3}
    retry_backoff = 5
    retry_jitter = True
    rate_limit = "20/m"


@app.task(base=BaseTaskWithRetry)
def validate_trial_subscriptions():
    monthly_lookback = 32  # in days
    annual_lookback = 4  # in days
    subscriptions = (
        Subscription.objects.filter(
            deleted_at__isnull=True,
        )
        .annotate(
            created_days_ago=ExpressionWrapper(
                ExtractDay(TransactionNow() - F("created_at")),
                output_field=IntegerField(),
            )
        )
        .filter(
            created_days_ago=Case(
                When(subscription_id="monthly_billing", then=monthly_lookback),
                When(subscription_id="annual_billing", then=annual_lookback),
            )
        )
    )
    logger.info("Validating trial subscriptions, count=%s", subscriptions.count())
    for subscription in subscriptions:
        validate_subscription.delay(subscription.id)


@app.task(base=BaseValidationTaskWithRetry)
def validate_subscription(subscription_id):
    try:
        logger.info("Validating subscription %s", subscription_id)
        subscription = Subscription.objects.get(
            pk=subscription_id, deleted_at__isnull=True
        )
        if not subscription.is_valid:
            logger.info(
                "Invalid or expired trial subscription %s",
                subscription_id,
            )
            # TODO add expiry date field in subscription
    except Subscription.DoesNotExist:
        return


class BaseRevenueCatTask(Task):
    rate_limit = "3/s"


@app.task(base=BaseRevenueCatTask)
def create_revenuecat_purchase(subscription_id):
	logger.info("Creating RevenueCat purchase [subscription_id=%s]", subscription_id)
	subscription = Subscription.objects.get(pk=subscription_id, deleted_at__isnull=True)
	try:
		result = revenuecat.create_purchase(
			subscription=subscription,
			create_events=True,
			update_last_seen=True,
			observer_mode=True,
		)
		logger.info("RevenueCat result: %s", result)
	except Exception as e:
		logger.error("Error creating RevenueCat purchase: %s", str(e))
