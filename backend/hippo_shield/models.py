import uuid
import stringcase

from django.db import models
from django.utils import timezone
from django.contrib.auth import get_user_model
from django.core.exceptions import PermissionDenied

from django.contrib.auth.models import PermissionsMixin
from django.contrib.auth.base_user import AbstractBaseUser
from django.contrib.auth.hashers import is_password_usable
from django.contrib.auth.hashers import check_password as c_p
from django.contrib.auth.hashers import make_password as django_make_password
from rest_framework.exceptions import NotAcceptable

from hippo_shield.managers import UserManager


class User(AbstractBaseUser, PermissionsMixin):
    class Meta:
        ordering = ['-date_joined']

    """Removing fields from AbstractBaseUser"""
    password = None
    last_login = None

    """UUID used to prevent object's count being exposed"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    """Date user joined to system"""
    date_joined = models.DateTimeField(auto_now_add=True)

    USERNAME_FIELD = 'id'
    REQUIRED_FIELDS = []

    objects = UserManager()

    @classmethod
    def additional_default_serializer_fields(cls):
        return {**super().additional_default_serializer_fields()}

    def get_username(self):
        try:
            if hasattr(self, 'email_password_authentication'):
                return self.email_password_authentication.email
            return super().get_username()
        except:
            return super().get_username()

    @property
    def is_staff(self):
        return True

    def __str__(self):
        if hasattr(self, 'profile'):
            return f'{self.profile.first_name} - {self.profile.last_name}'
        return f'{self.id}'


class AuthenticationBackend(models.Model):
    class Meta:
        abstract = True

    user = models.OneToOneField(
        get_user_model(),
        on_delete=models.CASCADE,
        related_name='email_password_authentication',
    )
    """UUID used to prevent object's count being exposed"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    @classmethod
    def get_identifier_field_name(cls):
        raise NotImplementedError

    @classmethod
    def find_object(cls, key):
        try:
            return cls.objects.get(**{cls.get_identifier_field_name(): key})
        except cls.DoesNotExist:
            pass

    @classmethod
    def register(cls, **kwargs):
        created = cls()
        created.verify_register(**kwargs)
        created.submit_register(**kwargs)
        return created

    @classmethod
    def login(cls, **kwargs):
        found = cls.find_object(kwargs[cls.get_identifier_field_name()])
        if not found:
            raise PermissionDenied()
        found.verify_login(**kwargs)
        found.submit_login(**kwargs)
        if not found.user.email_password_authentication.check_password(
            kwargs['password']
        ):
            raise PermissionDenied()
        return found

    def logout(self, **kwargs):
        self.submit_logout(**kwargs)
        return self

    def _verify_register(self, **data):
        """
        Verifies if registration is permitted
        """

        """Checks for duplicate backend setting for user"""
        user = data.get('user', User.objects.create_user())
        if hasattr(user, stringcase.snakecase(self.__class__)):
            raise NotAcceptable({"detail": "created for User previously"})
        self.user = user

        """Checks for registering with existing identifier"""
        identifier = data[self.get_identifier_field_name()]
        if self.find_object(key=identifier):
            raise NotAcceptable({"detail": "user already exists"})

        setattr(self, self.get_identifier_field_name(), identifier)

    def verify_register(self, **data):
        """
        Verifies if registration is permitted
        """
        pass

    def verify_login(self, **data):
        """
        Verifies if login is permitted
        """
        pass

    def verify_activity(self, **data):
        """
        Verifies if activity is permitted
        """

    def submit_register(self, **data):
        """
        Submits registration data
        """
        self.save()

    def submit_login(self, **data):
        """
        Submits login data
        """
        self.save()

    def submit_logout(self, **data):
        """
        Submits logout data
        """
        self.save()

    def submit_activity(self, **data):
        """
        Submits activity data
        """
        self.save()


def make_password(password=None, salt=None, hasher='default'):
    return django_make_password(password, salt, hasher)


class PasswordAuthenticationBackend(AuthenticationBackend):
    class Meta:
        abstract = True

    """Hashed password field"""
    password = models.CharField(max_length=255, default=make_password)

    """Last date password changed"""
    date_password_changed = models.DateTimeField(blank=True, null=True)

    @classmethod
    def get_identifier_field_name(cls):
        raise NotImplementedError

    def set_password(self, raw_password):
        """
        Sets password if current password differs from old one
        :return: True if password changed
        """
        if self.check_password(raw_password):
            return False
        self.password = make_password(raw_password)
        self.date_password_changed = timezone.now()
        return True

    def check_password(self, raw_password):
        return c_p(password=raw_password, encoded=self.password)

    def set_unusable_password(self):
        """
        Set a value that will never be a valid hash
        """
        self.password = make_password(None)

    def has_usable_password(self):
        """
        Return False if set_unusable_password() has been called for this user.
        """
        if self.password is None:
            return False
        return is_password_usable(self.password)

    def _verify_register(self, **data):
        pass

    def _submit_register(self, **data):
        if 'password' in data.keys():
            self.set_password(data['password'])


class EmailPasswordAuthentication(PasswordAuthenticationBackend):
    email = models.EmailField(unique=True)

    @classmethod
    def get_identifier_field_name(cls):
        return 'email'

    def __str__(self):
        return self.email


from django.contrib.auth.backends import ModelBackend


class EmailPasswordAuthenticationBackend(ModelBackend):
    def authenticate(self, request, username=None, password=None, **kwargs):
        return EmailPasswordAuthentication.login(email=username, password=password).user
