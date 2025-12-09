import time
import logging

from financial.models import Subscription
from financial.integrations import revenuecat


logger = logging.getLogger(__name__)

DEFAULT_BATCH_SIZE = 10


def _subscriptions_queryset(after_id=None):
    qs = Subscription.objects.filter(deleted_at__isnull=True).order_by("id")
    if after_id is not None:
        qs = qs.filter(id__gt=after_id)
    return qs


def _import_subscriptions(batch_size=DEFAULT_BATCH_SIZE):
    last_id, count = None, 0
    batch_id = 0

    while True:
        queryset = _subscriptions_queryset(last_id)
        subscriptions = list(queryset[:batch_size])

        if not subscriptions:
            break

        batch_id += 1
        for s in subscriptions:
            try:
                result = revenuecat.create_purchase(
                    subscription=s,
                    create_events=False,
                    update_last_seen=False,
                    observer_mode=True
                )
                logger.info("Created purchase [subscription=%s, result=%s]", s, result)
                count += 1
            except Exception as e:
                logger.error("Error creating purchase: %s", str(e))

        last_id = subscriptions[-1].id
        logger.info("Processed batch %s, last_id=%s", batch_id, last_id)
        time.sleep(5)

    logger.info("Done, count=%s", count)



def run():
    _import_subscriptions()
