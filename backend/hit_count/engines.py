from redis import Redis
from functools import cache
from typing import List, Tuple

from .settings import (
    REDIS_URL,
    REDIS_DB,
    CACHE_KEY_PREFIX,
    CACHE_KEY_SEPARATOR,
    TIME_ZONE,
)
from .enums import TimeWindow
from .utils import now_at_timezone


class RedisEngine:
    def __init__(self):
        self._redis = Redis.from_url(
            url=REDIS_URL,
            db=REDIS_DB,
            decode_responses=True,
        )

    def _get_truncated_timestamp(self, window: TimeWindow) -> int:
        dt = now_at_timezone(TIME_ZONE).replace(second=0, microsecond=0)
        if window == TimeWindow.Minute:
            pass
        elif window == TimeWindow.Hour:
            dt = dt.replace(minute=0)
        elif window == TimeWindow.Day:
            dt = dt.replace(hour=0, minute=0)
        return int(dt.timestamp())

    @cache
    def _get_redis_key(self, entity: str, bucket: str) -> str:
        return CACHE_KEY_SEPARATOR.join(
            [
                CACHE_KEY_PREFIX,
                entity.lower(),
                bucket,
            ]
        )

    def get_entity_key(self, entity: str, window: TimeWindow, offset=0) -> str:
        bucket = str(self._get_truncated_timestamp(window) + (offset * window))
        key = self._get_redis_key(entity, bucket)
        return key

    def hit(self, entity: str, entity_id: str | int) -> None:
        pipe = self._redis.pipeline()
        for window in (TimeWindow.Hour, TimeWindow.Day):
            key = self.get_entity_key(entity, window)
            pipe.zincrby(key, 1, str(entity_id))
            # remove key in 90 days
            pipe.expire(key, 90 * TimeWindow.Day.value)
        pipe.execute()

    def get_counts(
        self,
        entity: str,
        window: TimeWindow,
        offset=0,
        desc=False,
    ) -> List[Tuple[str, int]]:
        """
        returns a list of (id, count) tuples for entity and time frame (window),
        sorted by desc/asc number of hits
        """
        key = self.get_entity_key(entity, window, offset=offset)
        return self._redis.zrange(key, 0, -1, withscores=True, desc=desc)
