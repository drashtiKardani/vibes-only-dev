from rest_framework import serializers

from hippo_shield.models import User


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = '__all__'


class LoginSerializer(serializers.Serializer):
    email = serializers.CharField()
    password = serializers.CharField()


class TwoFALoginSerializer(serializers.Serializer):
    code = serializers.CharField()
