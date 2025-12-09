from crum import get_current_request


def is_application_request():
    return get_current_request().META.get('HTTP_PLATFORM') in ['ios', 'android']


def is_android_request():
    return get_current_request().META.get('HTTP_PLATFORM') == 'android'