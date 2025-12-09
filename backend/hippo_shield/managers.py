from django.contrib.auth.base_user import BaseUserManager


class UserManager(BaseUserManager):
    use_in_migrations = True

    def _create_user(self, **extra_fields):
        """
        Creates and saves a User
        """

        """Prevents direct id setting, to solve uuid4 uniqueness by time issue"""
        if 'id' in extra_fields.keys():
            del extra_fields['id']
        user = self.model(**extra_fields)
        user.save()
        return user

    def create_user(self, **extra_fields):
        extra_fields['is_superuser'] = False
        return self._create_user(**extra_fields)

    def create_superuser(self, **extra_fields):
        extra_fields['is_superuser'] = True
        return self._create_user(**extra_fields)
