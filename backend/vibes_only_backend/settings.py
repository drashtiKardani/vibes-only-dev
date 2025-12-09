import os
import environ
import datetime
import sentry_sdk
from pathlib import Path
from firebase_admin import initialize_app, credentials
from sentry_sdk.integrations.django import DjangoIntegration

env = environ.Env()

BASE_DIR = Path(__file__).resolve().parent.parent
SECRET_KEY = env('SECRET_KEY')
DEBUG = env.bool('DEBUG', default=False)

LOCAL = 'local'
FEAT = 'feat'
STAGE = 'stage'
PRODUCTION = 'prod'
ENVIRONMENT = env('ENVIRONMENT', default='feat')

ALLOWED_HOSTS = [
    '127.0.0.1',
    'localhost',
    'vo-feat.6thsolution.tech',
    'vo-panel.6thsolution.tech',
    'vo-api.6thsolution.com',
    'app.vibesonly.com',
    'admin78.vibesonly.com',
    'share.vibesonly.com',
]

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django.contrib.postgres',
    'rest_framework',
    'rest_framework_simplejwt',
    "corsheaders",
    "django_filters",
    'sortedm2m',
    "fcm_django",
    'fsm_admin',
    'django_fsm',
    'django_extensions',
    'hippo_heart',
    'hippo_shield',
    'stories',
    'studio',
    'users',
    'videos',
    'log',
    'financial',
]

MIDDLEWARE = [
    "corsheaders.middleware.CorsMiddleware",
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'hit_count.middleware.CachedHitCountMiddleware',
    'crum.CurrentRequestUserMiddleware',
]

ROOT_URLCONF = 'vibes_only_backend.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / "templates"],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'vibes_only_backend.wsgi.application'


DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'HOST': 'vibes_only_db',
        'NAME': 'postgres',
        'USER': 'postgres',
        'PASSWORD': env('DB_DEFAULT_PASS'),
    }
}


AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_L10N = True
USE_TZ = True

STATIC_URL = '/static/'
STATIC_ROOT = 'static'
MEDIA_URL = '/media/'
MEDIA_ROOT = 'media'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# Mail
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = env('EMAIL_HOST')
EMAIL_HOST_USER = env('EMAIL_HOST_USER')
EMAIL_HOST_PASSWORD = env('EMAIL_HOST_PASSWORD')
EMAIL_PORT = int(env('EMAIL_PORT'))
EMAIL_USE_TLS = env('EMAIL_USE_TLS')

CORS_ALLOW_ALL_ORIGINS = True

# Authentication
AUTH_USER_MODEL = 'hippo_shield.User'
AUTHENTICATION_BACKENDS = ['hippo_shield.models.EmailPasswordAuthenticationBackend']

# Logging
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '%(levelname)s %(asctime)s %(module)s '
            '%(process)d %(thread)d %(message)s'
        }
    },
    'handlers': {
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
        "django-file": {
            "level": "DEBUG",
            "class": "logging.FileHandler",
            "filename": "/var/log/vo/django.log",
            'formatter': 'verbose',
        },
        "financial-file": {
            "level": "DEBUG",
            "class": "logging.FileHandler",
            "filename": "/var/log/vo/financial.log",
            'formatter': 'verbose',
        },
        "celery-file": {
            "level": "DEBUG",
            "class": "logging.FileHandler",
            "filename": "/var/log/vo/celery.log",
            'formatter': 'verbose',
        },
    },
    'loggers': {
        '': {
            'level': 'WARNING',
            'handlers': ['console'],
        },
        'financial': {
            'level': 'DEBUG' if DEBUG else 'INFO',
            'handlers': ['console', 'financial-file'],
            'propagate': False,
        },
        'celery': {
            'level': 'DEBUG' if DEBUG else 'INFO',
            'handlers': ['console', 'celery-file'],
            'propagate': False,
        },
        'django': {
            'level': 'INFO',
            'handlers': ['console', 'django-file'],
            'propagate': False,
        },
        'urllib3': {
            'level': 'DEBUG' if DEBUG else 'WARNING',
            'handlers': ['console'],
            'propagate': False,
        }
    },
    'root': {
        'handlers': ['console'],
        'level': 'WARNING',
    },
}

# djangorestframework
REST_FRAMEWORK = {
    'DEFAULT_FILTER_BACKENDS': (
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ),
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.LimitOffsetPagination',
}

# djangorestframework-simplejwt
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': datetime.timedelta(days=356 * 10),
    'REFRESH_TOKEN_LIFETIME': datetime.timedelta(days=365 * 10),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'UPDATE_LAST_LOGIN': True,
}


# Celery
CELERY_BROKER_URL = 'redis://vibes_only_redis:6379/0'
BROKER_URL = CELERY_BROKER_URL
REDIS_URL = 'redis://vibes_only_redis:6379'

# Sentry
SENTRY_DSN = env('SENTRY_DSN', default=None)
if SENTRY_DSN:
    sentry_sdk.init(
        dsn=SENTRY_DSN,
        integrations=[DjangoIntegration()],
        traces_sample_rate=1.0,
        send_default_pii=True,
        environment=ENVIRONMENT,
    )


# Amazon
AWS_ACCESS_KEY_ID = env("AWS_S3_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY = env("AWS_S3_SECRET_ACCESS_KEY")
AWS_STORAGE_BUCKET_NAME = env("AWS_STORAGE_BUCKET_NAME")
AWS_S3_CUSTOM_DOMAIN = f'{AWS_STORAGE_BUCKET_NAME}.s3.amazonaws.com'
AWS_S3_SIGNATURE_VERSION = "s3v4"
AWS_S3_OBJECT_PARAMETERS = {'CacheControl': 'max-age=86400'}
AWS_PUBLIC_MEDIA_LOCATION = 'media'
AWS_STATIC_LOCATION = 'static'
AWS_PRIVATE_MEDIA_LOCATION = 'management'
if ENVIRONMENT != LOCAL:
    STATIC_URL = f'https://{AWS_S3_CUSTOM_DOMAIN}/{AWS_STATIC_LOCATION}/'
MEDIA_URL = f'https://{AWS_S3_CUSTOM_DOMAIN}/{AWS_PUBLIC_MEDIA_LOCATION}/'
AWS_ARTIFACTS_RULE = env('AWS_ARTIFACTS_RULE')
AWS_S3_REGION_NAME = 'us-east-2'
AWS_S3_FILE_OVERWRITE = False
AWS_QUERYSTRING_AUTH = False
AWS_DEFAULT_ACL = "public-read"
AWS_S3_VERIFY = True

# django-storage
DEFAULT_FILE_STORAGE = 'reusable.storages.MediaStorage'
PRIVATE_FILE_STORAGE = 'reusable.storages.PrivateMediaStorage'
if ENVIRONMENT != LOCAL:
    STATICFILES_STORAGE = 'reusable.storages.StaticStorage'

# django fsm
FCM_SERVER_KEY = env('FCM_SERVER_KEY', default=None)
FIREBASE_CREDENTIAL_JSON_PATH = env('FIREBASE_CREDENTIAL_JSON_PATH', default=None)
TEMPLATE_CONTEXT_PROCESSORS = ("django.core.context_processors.request",)
if (
    ENVIRONMENT in [STAGE, FEAT, PRODUCTION]
    and FIREBASE_CREDENTIAL_JSON_PATH
    and FCM_SERVER_KEY
):
    cred = credentials.Certificate(
        os.path.join(BASE_DIR, FIREBASE_CREDENTIAL_JSON_PATH)
    )
    initialize_app(cred)
    FCM_DJANGO_SETTINGS = {
        "ONE_DEVICE_PER_USER": False,
        "UPDATE_ON_DUPLICATE_REG_ID": True,
        "FCM_SERVER_KEY": FCM_SERVER_KEY,
    }

# twilio
TWILIO_SID = env('TWILIO_SID')
TWILIO_TOKEN = env('TWILIO_TOKEN')

# address
BACKEND_URL = env('BACKEND_URL')

# Google Play
GOOGLE_PLAY_CREDENTIAL_JSON_PATH = env.str('GOOGLE_PLAY_CREDENTIAL_JSON_PATH')
GOOGLE_BUNDLE_ID = 'com.vibesonly.app'

# Apple Store
APPLE_BUNDLE_ID = 'com.vibesonly.app'
APPLE_SHARED_SECRET = env('APPLE_SHARED_SECRET')

# cache backend
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://vibes_only_redis:6379/1',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        },
    }
}

SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

# Cloudfront access limit
CLOUDFRONT_KEY_ID = env('CLOUDFRONT_KEY_ID')
CLOUDFRONT_PRIVATE_KEY_PATH = env('CLOUDFRONT_PRIVATE_KEY_PATH')

# hit count app settings
HIT_COUNT = {
    'CACHE_PREFIX': '_hit_count',
    'REDIS_URL': REDIS_URL,
    'REDIS_DB': 9,
    'TIME_ZONE': 'America/Toronto',
    'URLS': {
        'story-detail': {
            'entity': 'Story'
        },
        'video-detail': {
            'entity': 'Video'
        }
    }
}

REVENUECAT_API_BASE_URL = 'https://api.revenuecat.com/v1'
REVENUECAT_API_KEY = env('REVENUECAT_API_KEY')
REVENUECAT_WEBHOOK_SECRET = env('REVENUECAT_WEBHOOK_SECRET')
