from __future__ import absolute_import
import os
from logging.config import dictConfig
from django.conf import settings
from celery import Celery
from celery.schedules import crontab
from celery.signals import setup_logging

# set the default Django settings module for the 'celery' program.
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "vibes_only_backend.settings")
app = Celery("vibes_only_backend")

# Using a string here means the worker will not have to
# pickle the object when using Windows.
app.config_from_object("django.conf:settings")
app.autodiscover_tasks(lambda: settings.INSTALLED_APPS)


@app.task(bind=True)
def debug_task(self):
    print("Request: {0!r}".format(self.request))


@setup_logging.connect
def config_loggers(*args, **kwags):
    dictConfig(settings.LOGGING)


app.conf.update(
    task_routes={
        "users.tasks.*": {
            "queue": "user-tasks",
        }
    }
)

app.conf.beat_schedule = {
    'update-story-view-counts': {
        'task': 'stories.tasks.update_view_counts',
        'schedule': crontab(hour='*', minute=1),
    },
    'update-video-view-counts': {
        'task': 'videos.tasks.update_view_counts',
        'schedule': crontab(hour='*', minute=1),
    },
    'queue-scheduled-push-messages': {
        'task': 'users.tasks.queue_scheduled_push_messages',
        'schedule': crontab(),  # every minute
    }
}
