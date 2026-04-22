import logging
from time import perf_counter
from uuid import uuid4

from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware

from app.logging_context import reset_request_id, set_request_id

logger = logging.getLogger("app.request")


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        request_id = request.headers.get("X-Request-ID") or uuid4().hex
        token = set_request_id(request_id)
        request.state.request_id = request_id
        start = perf_counter()

        try:
            response = await call_next(request)
        except Exception:
            duration_ms = (perf_counter() - start) * 1000
            client_host = request.client.host if request.client else "-"
            logger.exception(
                "request_failed method=%s path=%s client=%s duration_ms=%.2f",
                request.method,
                request.url.path,
                client_host,
                duration_ms,
            )
            reset_request_id(token)
            raise

        duration_ms = (perf_counter() - start) * 1000
        client_host = request.client.host if request.client else "-"
        response.headers["X-Request-ID"] = request_id
        logger.info(
            "request_completed method=%s path=%s status_code=%s client=%s duration_ms=%.2f",
            request.method,
            request.url.path,
            response.status_code,
            client_host,
            duration_ms,
        )
        reset_request_id(token)
        return response
