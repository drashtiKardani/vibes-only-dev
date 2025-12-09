from django.urls import path

from reusable.other import trigger_error

urlpatterns = [
    path("test-sentry/", trigger_error),
]
