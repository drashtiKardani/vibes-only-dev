import logging
from django.http import HttpRequest, HttpResponse
from django.core.exceptions import MiddlewareNotUsed

from .engines import RedisEngine
from .settings import URLS

logger = logging.getLogger(__name__)


class CachedHitCountMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response
        if not URLS:
            raise MiddlewareNotUsed()
        self._engine = RedisEngine()

    def __call__(self, request):
        response = self.get_response(request)
        try:
            self._process_hit_count(request, response)
        except Exception as ex:
            logger.error("Error processing hit count, %s", ex)
        return response

    def _process_hit_count(self, request: HttpRequest, response: HttpResponse):
        if request.method != "GET" or response.status_code != 200:
            return

        match = request.resolver_match
        if not match or match.url_name not in URLS:
            return

        # TODO don't count admin panel requests as hits
        entity = URLS[match.url_name].get("entity", "unknown")
        entity_id = match.kwargs.get("pk")
        self._engine.hit(entity=entity, entity_id=entity_id)
