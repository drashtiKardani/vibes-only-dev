from django.urls import path
from rest_framework.routers import DefaultRouter

from . import views

router = DefaultRouter()
router.register(r"promotions", views.PromotionViewSet, basename="promotion")

urlpatterns = [
    path(
        "google_verify_purchase_v2/",
        views.GoogleVerifyPurchaseV2View.as_view(),
        name="verify-purchase-v2",
    ),
    path(
        "google_verify_purchase/",
        views.GoogleVerifyPurchaseView.as_view(),
        name="verify-purchase",
    ),
    path(
        "apple_verify_purchase/",
        views.AppleVerifyPurchaseView.as_view(),
        name="verify-purchase",
    ),
    path(
        "revenuecat/webhook/",
        views.RevenueCatWebHook.as_view(),
        name="revenuecat-webhook",
    ),
]
urlpatterns += router.urls
