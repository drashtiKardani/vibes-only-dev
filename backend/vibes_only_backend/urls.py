from django.contrib import admin
from django.conf import settings
from django.urls import path, include
from django.conf.urls.static import static


urlpatterns = (
    [
        path('secret-admin/', admin.site.urls),
        path('api/v1/stories/', include('stories.urls')),
        path('api/v1/users/', include('users.urls')),
        path('api/v1/videos/', include('videos.urls')),
        path('api/v1/studio/', include('studio.urls')),
        path('api/v1/financial/', include('financial.urls')),
        path('api/v1/log/', include('log.urls')),
        path('api/v1/hippo_shield/', include('hippo_shield.urls')),
    ]
    + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
)

admin.site.site_header = "VO Administration Panel"
admin.site.index_title = "VO"
admin.site.site_title = "VO Admin"
