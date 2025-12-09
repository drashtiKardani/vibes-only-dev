import logging
import requests
from django.conf import settings
from typing import Any, Dict, Optional

from ..models import Subscription


logger = logging.getLogger(__name__)


def create_purchase(
    *,
    subscription: Subscription,
    attributes: Optional[Dict[str, Any]] = {},
    create_events=True,
    update_last_seen=True,
    observer_mode=True,
) -> bool:
    """
    see https://www.revenuecat.com/reference/receipts
    """

    if not subscription:
        logger.warn("Invalid subscription %s", subscription)
        return False
    if not subscription.token:
        logger.warn("Subscription token missing")
        return False
    if not subscription.subscription_id or not subscription.device_id:
        logger.warn(
            "Subscription missing a required parameter "
            "[subscription_id=%s, device_id=%s]",
            subscription.subscription_id,
            subscription.device_id,
        )
        return False

    url = f"{settings.REVENUECAT_API_BASE_URL}/receipts"
    payload = {
        "product_id": subscription.subscription_id,
        "app_user_id": subscription.device_id,
        "fetch_token": subscription.token,
        "create_events": create_events,
        "should_update_last_seen_fields": update_last_seen,
        "observer_mode": observer_mode,
        "attributes": attributes,
    }
    if (price := subscription.price) is not None:
        payload |= {"price": price, "currency": "USD"}
    headers = {
        "X-Platform": str(subscription.app_platform).lower(),
        "Authorization": f"Bearer {settings.REVENUECAT_API_KEY}",
    }

    response = requests.post(url, json=payload, headers=headers)
    response.raise_for_status()

    return response.ok
