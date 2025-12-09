import boto3
import logging
import functools
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import padding
from botocore.signers import CloudFrontSigner


from django.conf import settings
from django.utils import timezone

logger = logging.getLogger(__name__)


def get_boto_session():
    return boto3.Session(
        aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
        aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
    )


def mediaconvert_get_job_template(client, template_name):
    return client.get_job_template(Name=template_name)['JobTemplate']


def mediaconvert_create_job(client, data):
    return client.create_job(**data)['Job']['Id']


def mediaconvert_get_job(client, job_id):
    return client.get_job(Id=job_id)['Job']


def mediaconvert_move_logo(job_data, width):
    job_data['Settings']['Inputs'][0]['ImageInserter']['InsertableImages'][0][
        'ImageInserterInput'
    ] = job_data['Settings']['Inputs'][0]['ImageInserter']['InsertableImages'][0][
        'ImageInserterInput'
    ].replace(
        's3://video-vibes/', f's3://{settings.AWS_STORAGE_BUCKET_NAME}/'
    )
    job_data['Settings']['Inputs'][0]['ImageInserter']['InsertableImages'][0][
        'ImageX'
    ] = int(width / 2) - int(
        job_data['Settings']['Inputs'][0]['ImageInserter']['InsertableImages'][0][
            'Width'
        ]
        / 2
    )
    return job_data


def mediaconvert_set_input(job_data, path):
    job_data['Settings']['Inputs'][0]['FileInput'] = path.replace(
        f'https://{settings.AWS_STORAGE_BUCKET_NAME}.s3.amazonaws.com',
        f's3://{settings.AWS_STORAGE_BUCKET_NAME}',
    )
    return job_data


def mediaconvert_clean_job(job_template_data):
    cleaned = {
        'AccelerationSettings': job_template_data['AccelerationSettings'],
        'Settings': job_template_data['Settings'],
        'JobTemplate': job_template_data['Name'],
        'Role': settings.AWS_ARTIFACTS_RULE,
    }
    for i in range(len(cleaned['Settings']['OutputGroups'])):
        cleaned['Settings']['OutputGroups'][i]['OutputGroupSettings'][
            'FileGroupSettings'
        ]['Destination'] = cleaned['Settings']['OutputGroups'][i][
            'OutputGroupSettings'
        ][
            'FileGroupSettings'
        ][
            'Destination'
        ].replace(
            's3://video-vibes/', f's3://{settings.AWS_STORAGE_BUCKET_NAME}/'
        )
    return cleaned


@functools.cache
def _get_cloudfront_private_key():
    with open(settings.CLOUDFRONT_PRIVATE_KEY_PATH, 'rb') as key_file:
        return serialization.load_pem_private_key(
            key_file.read(),
            password=None,
            backend=default_backend()
        )


def _rsa_signer(message):
    private_key = _get_cloudfront_private_key()
    return private_key.sign(message, padding.PKCS1v15(), hashes.SHA1())


def generate_signed_url_of_cdn_url(url, expire_hours):
    expire_at = timezone.localtime() + timezone.timedelta(hours=expire_hours)
    key_id = settings.CLOUDFRONT_KEY_ID
    cloudfront_signer = CloudFrontSigner(key_id, rsa_signer=_rsa_signer)

    return cloudfront_signer.generate_presigned_url(
        url, date_less_than=expire_at
    )
