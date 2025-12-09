import os
import json
import math
import time
import sqlite3
from django.conf import settings
from inapppy.appstore import AppStoreValidator
from inapppy.googleplay import GooglePlayVerifier

from financial.models import Subscription

SQLITE_DB = "subscriptions.db"
DEFAULT_BATCH_SIZE = 20


def _parse_int_str(value):
    if value is not None:
        try:
            return int(value)
        except:
            pass
    return None


def _prepare_sqlite_db():
    con = sqlite3.connect(SQLITE_DB)
    cur = con.cursor()

    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS subscription (
            id PRIMARY KEY,
            device_id,
            token,
            environment,
            subscription_id,
            app_platform,
            result,
            purchase_date_ms,
            expires_date_ms,
            cancellation_date_ms
        )
        """
    )
    cur.execute("DELETE FROM subscription")
    con.commit()

    return (con, cur)


def _subscriptions_queryset():
    return (
        Subscription.objects
            .filter(deleted_at__isnull=True)
            .order_by("-created_at")
    )


def _fetch_subscriptions():
    count = 0
    batch_size = DEFAULT_BATCH_SIZE

    (db_con, db_cur) = _prepare_sqlite_db()
    apple_validator = AppStoreValidator(
        settings.APPLE_BUNDLE_ID,
        auto_retry_wrong_env_request=True
    )
    google_validator = GooglePlayVerifier(
        settings.GOOGLE_BUNDLE_ID,
        settings.GOOGLE_PLAY_CREDENTIAL_JSON_PATH,
    )

    while True:
        subscriptions = list(_subscriptions_queryset()[count : count + batch_size])
        if not subscriptions:
            break

        print(f"{subscriptions=}")

        for s in subscriptions:
            count += 1

            if not s:
                continue

            result, ok = None, False
            purchase_date_ms, expires_date_ms, cancellation_date_ms = None, None, None
            try:
                if s.app_platform != Subscription.AppPlatform.ANDROID:
                    # App store (Apple) or unknown platform
                    result = apple_validator.validate(
                        s.token,
                        settings.APPLE_SHARED_SECRET,
                        exclude_old_transactions=True,
                    )
                    environment = result.get("environment")
                    latest_receipt_info = result["latest_receipt_info"][0]
                    purchase_date_ms = _parse_int_str(latest_receipt_info.get("purchase_date_ms"))
                    expires_date_ms = _parse_int_str(latest_receipt_info.get("expires_date_ms"))
                    cancellation_date_ms = _parse_int_str(latest_receipt_info.get("cancellation_date_ms"))
                    ok = not bool(result.get("status")) if result else False
                else:
                    # Play store (Google)
                    result = google_validator.verify_with_result(
                        s.token,
                        s.subscription_id,
                        is_subscription=True,
                    )
                    raw_response = result.raw_response
                    purchase_date_ms = _parse_int_str(raw_response.get("startTimeMillis"))
                    expires_date_ms = _parse_int_str(raw_response.get("expiryTimeMillis"))
                    cancellation_date_ms = _parse_int_str(raw_response.get("userCancellationTimeMillis"))
                    result = raw_response
                    ok = True

                record = (
                    s.id,
                    s.device_id,
                    s.token,
                    environment,
                    s.subscription_id,
                    s.app_platform,
                    json.dumps(result) if result else None,
                    purchase_date_ms,
                    expires_date_ms,
                    cancellation_date_ms,
                )
                db_cur.execute(
                    """
                    INSERT INTO subscription (
                        id,
                        device_id,
                        token,
                        environment,
                        subscription_id,
                        app_platform,
                        result,
                        purchase_date_ms,
                        expires_date_ms,
                        cancellation_date_ms
                    )
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    record,
                )
                db_con.commit()
            except Exception as e:
                print("Error processing subscription id={0:<6}, error={1}".format(s.id, e))
            else:
                print("Processed subscription id={0:<6}, ok={1}".format(s.id, ok))

        print(f"Finished batch ", math.ceil(count / batch_size))
        time.sleep(5)


def run():
    if os.path.exists(SQLITE_DB):
        os.remove(SQLITE_DB)
    _fetch_subscriptions()