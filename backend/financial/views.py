import logging
from googleapiclient.discovery import build
from googleapiclient.discovery import service_account

from django.conf import settings
from django.shortcuts import get_object_or_404
from django.db.models import F
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.viewsets import ModelViewSet
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticatedOrReadOnly, AllowAny

from .integrations.apple import appstore
from .integrations.google import playstore
from . import serializers, models, tasks

logger = logging.getLogger(__name__)


class GoogleVerifyPurchaseV2View(APIView):
    def post(self, request):
        serializer = serializers.VerifyPurchaseSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        bundle_id = 'com.vibesonly.app'
        credentials = service_account.Credentials.from_service_account_file(
            settings.FIREBASE_CREDENTIAL_JSON_PATH
        )
        # Build the "service" interface to the API you want
        service = build("androidpublisher", "v3", credentials=credentials)
        # Use the token your API got from the app to verify the purchase
        try:
            result = (
                service.purchases()
                .subscriptions()
                .get(
                    packageName=bundle_id,
                    subscriptionId=data['subscription_id'],
                    token=data['token'],
                )
                .execute()
            )
            logger.error(result)
            return Response({'status': 'Success'})
        except Exception as e:
            logger.error(e)
            return Response({'status': 'Failed'}, status=status.HTTP_400_BAD_REQUEST)


class GoogleVerifyPurchaseView(APIView):
    def post(self, request):
        serializer = serializers.GoogleVerifyPurchaseSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        token = data.get('token')
        device_id = data.get('device_id')
        subscription_id = data.get('subscription_id')

        result = playstore.validate_google_token(token, subscription_id)
        logger.info(
            "Post google verify purchase, device_id=%s, result=%s",
            device_id,
            str(result)
        )
        if not result.valid:
            logger.warn(f'Invalid subscription [device_id=%s]', device_id)
            return Response(
                status=status.HTTP_400_BAD_REQUEST,
                data={
                    'valid': False,
                    'exp': result.expires_at,
                    'g_resp': '',
                },
            )

        subscription, _ = models.Subscription.objects.update_or_create(
            device_id=device_id,
            defaults={
                'token': token,
                'subscription_id': subscription_id,
                'app_platform': models.Subscription.AppPlatform.ANDROID,
                'deleted_at': None,
            },
        )
        return Response(
            {
                'valid': True,
                'transaction_id': result.transaction_id,
                'exp': result.expires_at,
                'package': subscription.package,
            }
        )

    def get(self, request):
        serializer = serializers.GetSubscriptionSerializer(data=request.GET)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        device_id = data['device_id']
        subscription = get_object_or_404(
            models.Subscription,
            device_id=device_id,
            deleted_at__isnull=True,
        )

        result = playstore.validate_google_token(
            subscription.token, subscription_id=subscription.subscription_id
        )
        logger.info(
            "Get google verify purchase, device_id=%s, result=%s",
            device_id,
            str(result)
        )
        if not result.valid:
            logger.warn(f'Invalid subscription [device_id=%s]', subscription.device_id)
            return Response(
                status=status.HTTP_400_BAD_REQUEST,
                data={
                    'valid': False,
                    'exp': result.expires_at,
                    'g_resp': '',
                },
            )

        return Response(
            {
                'valid': True,
                'transaction_id': result.transaction_id,
                'exp': subscription.exp_date,
                'package': subscription.package,
            }
        )


class AppleVerifyPurchaseView(APIView):
    def post(self, request):
        serializer = serializers.AppleVerifyPurchaseSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        device_id = data['device_id']
        token = data['token']

        result = appstore.validate_apple_token(token)
        logger.info(
            "Post apple verify purchase, device_id=%s, result=%s",
            device_id,
            str(result)
        )
        if not result.valid:
            logger.warn(f'Invalid subscription [device_id=%s]', device_id)
            return Response(
                status=status.HTTP_400_BAD_REQUEST,
                data={
                    'valid': False,
                    'a_resp': '',
                }
            )

        subscription, created = models.Subscription.objects.update_or_create(
            device_id=data['device_id'],
            defaults={
                'token': token,
                'subscription_id': result.product_id,
                'app_platform': models.Subscription.AppPlatform.IOS,
                'deleted_at': None,
            },
        )
        if created and getattr(settings, 'ENVIRONMENT', None) == settings.PRODUCTION:
            tasks.create_revenuecat_purchase.delay(subscription.id)

        return Response(
            {
                'valid': True,
                'transaction_id': result.transaction_id,
                'exp': result.expires_at,
                'package': subscription.package,
            }
        )

    def get(self, request):
        serializer = serializers.GetSubscriptionSerializer(data=request.GET)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        subscription = get_object_or_404(
            models.Subscription,
            device_id=data['device_id'],
            deleted_at__isnull=True,
        )

        result = appstore.validate_apple_token(subscription.token)
        logger.info(
            "Get apple verify purchase, device_id=%s, result=%s",
            data.get("device_id"),
            str(result)
        )
        if not result.valid:
            logger.warn(f'Invalid subscription [device_id=%s]', subscription.device_id)
            return Response(
                status=status.HTTP_400_BAD_REQUEST,
                data={
                    'valid': False,
                    'exp': result.expires_at,
                    'a_resp': '',
                },
            )

        return Response(
            {
                'valid': True,
                'transaction_id': result.transaction_id,
                'exp': subscription.exp_date,
                'package': subscription.package,
            }
        )


class PromotionViewSet(ModelViewSet):
    permission_classes = (IsAuthenticatedOrReadOnly,)
    queryset = models.Promotion.objects.filter(deleted_at=None)
    serializer_class = serializers.PromotionSerializer

    @action(detail=False, methods=["POST"], permission_classes=[AllowAny])
    def visits(self, request):
        serializer = serializers.PromotionVisitInputSerializer(
            data=request.data
        )
        serializer.is_valid(raise_exception=True)
        uid = serializer.validated_data.get("uid")

        updated_count = models.Promotion.objects.filter(
            uid=uid,
        ).update(
            visit_count=F("visit_count") + 1,
        )
        status = "Success" if updated_count == 1 else "Failed"

        return Response({"status": status})


class RevenueCatWebHook(APIView):
    authentication_classes = []

    def post(self, request):
        secret = getattr(settings, "REVENUECAT_WEBHOOK_SECRET")
        auth_header = request.headers.get("authorization")
        if not auth_header:
            return Response(status=status.HTTP_401_UNAUTHORIZED)

        scheme, auth = auth_header.split(" ", 1)
        if (
            not scheme or scheme.lower() != "bearer"
            or not auth or auth.strip() != secret
        ):
            return Response(status=status.HTTP_401_UNAUTHORIZED)

        event = request.data.get("event")
        logger.info("revenuecat event: %s", event)

        if event.get("type") in [
            "INITIAL_PURCHASE",
            "RENEWAL",
            "NON_RENEWING_PURCHASE",
        ]:
            if offer_code := event.get("offer_code"):
                logger.info(
                    "updating offer code usage, offer_code=%s", offer_code
                )
                # 'code' is the full url
                # eg https://apps.apple.com/redeem?ctx=offercodes&id=160&code=15ANNUAL
                models.Promotion.objects.filter(
                    code__iregex=rf"\Wcode={offer_code}(?:\W|$)",
                ).update(
                    usage_count=F("usage_count") + 1,
                )

        return Response(status=status.HTTP_200_OK)
