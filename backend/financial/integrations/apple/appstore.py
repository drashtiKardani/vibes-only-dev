import logging
from datetime import datetime
from collections import namedtuple
from django.conf import settings
from inapppy.appstore import AppStoreValidator, InAppPyValidationError
from toolz import dicttoolz, itertoolz

logger = logging.getLogger(__name__)


AppleValidationResult = namedtuple(
    "AppleValidationResult",
    ["valid", "expires_at", "transaction_id", "product_id"],
)


def validate_apple_token(token: str) -> AppleValidationResult:
    validator = AppStoreValidator(
        settings.APPLE_BUNDLE_ID, auto_retry_wrong_env_request=True
    )

    valid, expires_at, transaction_id, product_id = (False, None, None, None)
    try:
        response = validator.validate(
            token,
            settings.APPLE_SHARED_SECRET,
            exclude_old_transactions=True,
        )
        logger.debug("App store response=%s", response)

        status = response["status"]
        receipt = dicttoolz.get_in(["latest_receipt_info", 0], response)
        transaction_id = itertoolz.get("original_transaction_id", receipt)
        product_id = itertoolz.get("product_id", receipt)

        expires_at_ms = itertoolz.get("expires_date_ms", receipt)
        canceled_at_ms = itertoolz.get("cancellation_date_ms", receipt, default=None)

        if canceled_at_ms:
            expires_at_ms = canceled_at_ms
        try:
            expires_at = datetime.fromtimestamp(int(expires_at_ms) / 1000)
        except TypeError:
            pass

        try:
            valid = bool(
                int(status) == 0
                and expires_at
                and expires_at > datetime.now()
            )
        except TypeError:
            valid = False
    except InAppPyValidationError as ex:
        logger.error("Error validating apple subscription, %s", ex)

    return AppleValidationResult(
        valid=valid,
        expires_at=expires_at,
        transaction_id=transaction_id,
        product_id=product_id,
    )
