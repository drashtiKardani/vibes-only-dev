from rest_framework.routers import DefaultRouter

from . import views

router = DefaultRouter()
router.register("characters", views.CharacterViewSet, basename="character")
router.register("categories", views.CategoryViewSet, basename="category")
router.register("stories", views.StoryViewSet, basename="story")
router.register("stories-studio", views.StoryStudioViewSet, basename="story-studio")
router.register("sections", views.SectionViewSet, basename="section")
router.register("homes", views.HomeViewSet, basename="home")

urlpatterns = []
urlpatterns += router.urls
