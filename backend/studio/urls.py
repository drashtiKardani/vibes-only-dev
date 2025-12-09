from rest_framework.routers import DefaultRouter

from . import views

router = DefaultRouter()
router.register("devices", views.DeviceViewSet, basename="device")
router.register("beats", views.BeatViewSet, basename="beat")
router.register("rhythms", views.RhythmViewSet, basename="rhythms")

urlpatterns = []
urlpatterns += router.urls
