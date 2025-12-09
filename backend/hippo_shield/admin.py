from django.contrib import admin

from .models import User


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ("pk", "get_username", "__str__")

    @admin.display(description="username")
    def get_username(self, instance):
        return instance.get_username()
