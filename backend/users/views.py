import logging

from django.db import transaction
from django.contrib.auth import get_user_model
from rest_framework import status, mixins
from fcm_django.models import FCMDevice
from rest_framework.views import APIView
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.viewsets import ModelViewSet, GenericViewSet
from rest_framework.permissions import IsAuthenticated

from . import serializers, models
from log import models as log_models
from videos import tasks as vid_tasks
from stories import tasks as str_tasks
from videos import models as vid_models
from stories import models as str_models
from hippo_shield.models import EmailPasswordAuthentication


logger = logging.getLogger(__name__)


class ProfileViewSet(ModelViewSet):
    permission_classes = (IsAuthenticated,)
    serializer_class = serializers.ProfileSerializer
    queryset = models.Profile.objects.all()

    @action(detail=False, methods=['post'])
    def add_device(self, request, format=None):
        with transaction.atomic():
            found = (
                FCMDevice.objects.filter(
                    registration_id=request.data['registration_id']
                )
                .order_by('-date_created')
                .first()
            )
            if found and found.user != self.request.user:
                FCMDevice.objects.filter(
                    registration_id=request.data['registration_id']
                ).delete()
                found = None
            if found is None:
                FCMDevice.objects.create(
                    registration_id=request.data['registration_id'],
                    type=request.data.get('type'),
                    device_id=request.data.get('device_id'),
                    name=request.data.get('name'),
                    user=request.user,
                )
        return Response(self.get_serializer(self.request.user.profile).data)


class StaffViewSet(ModelViewSet):
    permission_classes = (IsAuthenticated,)
    serializer_class = serializers.StaffSerializer
    queryset = models.Staff.objects.order_by('-id')

    @action(detail=False, methods=['post'])
    def register(self, request, format=None):
        with transaction.atomic():
            user = get_user_model().objects.create_user()
            epa = EmailPasswordAuthentication.objects.create(
                email=request.data['email'], user=user
            )
            epa.set_password(request.data["password"])
            epa.save()
            staff = models.Staff.objects.create(
                user=epa.user,
                phone_number=request.data['phone_number'],
                first_name=request.data['first_name'],
                last_name=request.data['last_name'],
            )
            return Response(
                serializers.StaffSerializer(staff).data, status.HTTP_201_CREATED
            )


class PushMessageViewSet(
    mixins.ListModelMixin,
    mixins.CreateModelMixin,
    mixins.DestroyModelMixin,
    GenericViewSet,
):
    permission_classes = (IsAuthenticated,)
    serializer_class = serializers.PushMessageSerializer
    queryset = models.PushMessage.objects.order_by("-id")


class TwilioLogAPIView(APIView):
    def post(self, request, *args, **kwargs):
        return Response(status=status.HTTP_200_OK)


class AWSWebhookAPIView(APIView):
    def post(self, request, *args, **kwargs):
        source = request.data['source']
        if source == 'aws.transcribe':
            job_name = request.data['detail']['TranscriptionJobName']
            status = request.data['detail']['TranscriptionJobStatus']
            log = log_models.AWSLog.objects.create(
                source=log_models.AWSLog.TRANSCRIBE, request=request.data, status=status
            )
            code = job_name.split('_')[0]
            if code == 'story':
                story = str_models.Story.objects.filter(
                    transcript_job_id=job_name
                ).first()
                if story:
                    if status == 'COMPLETED':
                        str_tasks.check_process_transcript.delay(story.pk)
            elif code == 'video':
                video = vid_models.Video.objects.filter(
                    transcript_job_id=job_name
                ).first()
                if video:
                    log.video = video
                    log.save()
                    if status == 'COMPLETED':
                        vid_tasks.check_vibes_video_transcript.delay(video.pk)
        elif source == 'aws.mediaconvert':
            job_id = request.data['detail']['jobId']
            status = request.data['detail']['status']
            log = log_models.AWSLog.objects.create(
                source=log_models.AWSLog.MEDIACONVERT,
                request=request.data,
                status=status,
            )
            video = vid_models.Video.objects.filter(
                quality_convert_job_id=job_id
            ).first()
            if video:
                log.video = video
                log.save()
                if status == 'COMPLETE':
                    vid_tasks.check_vibes_video_quality_convert.delay(video.pk)
            else:
                video = vid_models.Video.objects.filter(
                    short_trimmer_job_id=job_id
                ).first()
                if video:
                    log.video = video
                    log.save()
                    if status == 'COMPLETE':
                        vid_tasks.check_vibes_video_short_trimmer.delay(video.pk)
        return Response()
