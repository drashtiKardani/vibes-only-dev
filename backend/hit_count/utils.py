from datetime import datetime
from pytz import timezone


def now_at_timezone(tzname: str) -> datetime:
    return datetime.now(tz=timezone(tzname))


def is_zero_hour_at_timezone(tzname: str) -> bool:
    return now_at_timezone(tzname).hour == 0
