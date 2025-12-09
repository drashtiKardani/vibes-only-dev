from rest_framework.throttling import UserRateThrottle


class LoginSMSMinuteThrottling(UserRateThrottle):
    def get_rate(self):
        return '10/minute'


class LoginSMSDayThrottling(UserRateThrottle):
    def get_rate(self):
        return '10/day'


def trigger_error(request):
    division_by_zero = 1 / 0
