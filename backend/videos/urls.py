from rest_framework.routers import DefaultRouter

from . import views

router = DefaultRouter()
router.register("channels", views.ChannelViewSet, basename="channel")
router.register("videos", views.VideoViewSet, basename="video")
router.register("creators", views.VideoCreatorViewSet, basename="creators")
router.register("media_uploads", views.MediaUploadViewSet, basename="media_upload")

urlpatterns = []
urlpatterns += router.urls
