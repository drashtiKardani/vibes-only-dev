from django.urls import path
from rest_framework.routers import DefaultRouter
from fcm_django.api.rest_framework import FCMDeviceViewSet

from users import views

router = DefaultRouter()
router.register('devices', FCMDeviceViewSet)
router.register("push_messages", views.PushMessageViewSet, basename="push-message")
router.register("profiles", views.ProfileViewSet, basename="profile")
router.register("staffs", views.StaffViewSet, basename="staff")

urlpatterns = [
    path("twilio_log/", views.TwilioLogAPIView.as_view(), name="twilio-log"),
    path("aws_webhook/", views.AWSWebhookAPIView.as_view(), name="aws-webhook"),
]
urlpatterns += router.urls
