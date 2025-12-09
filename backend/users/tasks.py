import json

from datetime import timedelta
from django.conf import settings
from django.utils import timezone
from django.db import transaction
from django.core.serializers.json import DjangoJSONEncoder
from celery import shared_task
from celery.utils.log import get_task_logger
from twilio.rest import Client
from firebase_admin.messaging import Message, Notification, send as fcm_send

from . import models
from log import models as log_models
from vibes_only_backend.celery_settings import app

logger = get_task_logger(__name__)


@app.task()
def queue_scheduled_push_messages():
    now = timezone.now()
    grace_period = timedelta(minutes=15)  # downtime grace period
    push_message_ids = set(
        models.PushMessage.objects.filter(
            scheduled_for__lte=now,
            scheduled_for__gt=now - grace_period,
            status=models.PushMessage.Status.SCHEDULED,
        ).values_list("pk", flat=True)
    )

    if not push_message_ids:
        return

    logger.info(
        "[check_for_scheduled_tasks] found %d scheduled tasks [message_ids=%s]",
        len(push_message_ids),
        push_message_ids,
    )
    for message_id in push_message_ids:
        logger.info("[check_for_scheduled_tasks] about to queue push message task, id=%s", message_id)
        send_push_message.delay(message_id)
        logger.info("queued push message task, id=%s", message_id)


@app.task()
def send_push_message(message_id):
    logger.info("[send_push_message] about to send push message, id=%s", message_id)
    try:
        with transaction.atomic():
            push_message = models.PushMessage.objects.select_for_update(
                skip_locked=True,
            ).filter(
                status=models.PushMessage.Status.SCHEDULED,
                deleted_at=None,
            ).get(pk=message_id)
            push_message.status = models.PushMessage.Status.SENDING
            push_message.save(update_fields=["status"])
    except models.PushMessage.DoesNotExist:
        # let other errors propagate without updating status
        logger.warn("invalid or deleted push message %s, skipping", message_id)
        return

    notification = Notification(title=push_message.title, body=push_message.body)
    data = (
        {k: str(v) for k, v in push_message.data.items() if v is not None}
        if push_message.data
        else None
    )
    topic = push_message.fcm_topic
    result, status = None, None
    try:
        if not topic:
            condition = push_message.fcm_all_target_condition
            fcm_message = Message(notification=notification, data=data, condition=condition)
        else:
            fcm_message = Message(notification=notification, data=data, topic=topic)
        result = fcm_send(fcm_message)
        status = models.PushMessage.Status.SENT
        logger.info("[send_push_message] successfully sent push message, id=%s", message_id)
    except Exception as e:
        result = str(e)
        status = models.PushMessage.Status.FAILED
        logger.error("[send_push_message] error sending push message, id=%s, error=%s", message_id, e)

    push_message.result = result
    push_message.status = status
    push_message.save()


@shared_task()
def send_sms(from_phone, to, body):
    client = Client(settings.TWILIO_SID, settings.TWILIO_TOKEN)
    log = log_models.TwilioLog.objects.create(
        from_number=from_phone,
        to=to,
        body=body,
    )
    try:
        message = client.messages.create(
            body=body,
            status_callback=f"{settings.BACKEND_URL}api/v1/users/twilio_log/",
            to=to,
            from_=from_phone,
        )
        log.send_data = json.loads(
            json.dumps(message._properties, cls=DjangoJSONEncoder)
        )
    except Exception as e:
        log.status_data = {"error": str(e)}
    log.save()


@shared_task()
def delete_2fa_code(staff_pk):
    staff = models.Staff.objects.get(pk=staff_pk)
    staff.two_fa_code = None
    staff.save()
