from django.urls import path

from . import views

urlpatterns = [
    path('main/refresh/', views.TokenRefreshView.as_view()),
    path('email_password_authentication/login/', views.LoginView.as_view()),
    path('2fa/login/', views.TwoFALoginView.as_view()),
]
