import logging
from datetime import datetime
from collections import namedtuple
from django.conf import settings
from inapppy.googleplay import GooglePlayVerifier, GoogleError
from toolz import itertoolz


logger = logging.getLogger(__name__)


GoogleValidationResult = namedtuple(
    "GoogleValidationResult",
    ["valid", "expires_at", "transaction_id"],
)


def validate_google_token(token: str, subscription_id: str) -> GoogleValidationResult:
    validator = GooglePlayVerifier(
        settings.GOOGLE_BUNDLE_ID,
        settings.GOOGLE_PLAY_CREDENTIAL_JSON_PATH,
    )

    valid, expires_at, transaction_id = (False, None, None)
    try:
        response = validator.verify(token, subscription_id, is_subscription=True)
        logger.debug("Play store response=%s", response)

        transaction_id = itertoolz.get('orderId', response)
        expires_at_ms = itertoolz.get('expiryTimeMillis', response)
        cancel_reason = itertoolz.get('cancelReason', response, default=None)

        if cancel_reason == 0:
            # subscription canceled by user
            expires_at_ms = itertoolz.get('userCancellationTimeMillis', response)

        try:
            expires_at = datetime.fromtimestamp(int(expires_at_ms) / 1000)
        except TypeError:
            pass

        try:
            valid = bool(
                cancel_reason is None
                and expires_at
                and expires_at > datetime.now()
            )
        except TypeError:
            valid = False
    except GoogleError as ex:
        logger.error("error validating google subscription, %s", ex)

    return GoogleValidationResult(
        valid=valid,
        expires_at=expires_at,
        transaction_id=transaction_id,
    )
