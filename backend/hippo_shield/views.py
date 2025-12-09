import logging

from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt import views as simplejwt_views

from users import models as usr_models
from hippo_shield.serializers import TwoFALoginSerializer, LoginSerializer

logger = logging.getLogger(__name__)


class LoginView(APIView):
    def post(self, request, *args, **kwargs):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        username = data["email"]
        password = data["password"]
        profile = usr_models.Profile.objects.filter(
            user__email_password_authentication__email__iexact=username
        ).first()
        if profile is None:
            return Response(
                {"detail": "user not found"},
                status=status.HTTP_401_UNAUTHORIZED,
            )
        if profile.user.email_password_authentication.check_password(password):
            data = dict()
            profile.set_login_code()
            profile.send_login_code()
            data["status"] = "Success"
            data["message"] = "Login code sent"
            return Response(data)
        return Response(
            {"detail": "incorrect password"},
            status=status.HTTP_401_UNAUTHORIZED,
        )


class TwoFALoginView(APIView):
    def post(self, request, *args, **kwargs):
        serializer = TwoFALoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        profile = None
        try:
            profile = usr_models.Profile.objects.get(two_fa_code=data['code'])
        except:
            return Response(
                data={'message': 'code not found', 'code': 404},
                status=status.HTTP_404_NOT_FOUND,
            )
        refresh = RefreshToken.for_user(profile.user)
        resp = {}
        resp['refresh'] = str(refresh)
        resp['access'] = str(refresh.access_token)
        return Response(resp)


class TokenRefreshView(simplejwt_views.TokenRefreshView):
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)
