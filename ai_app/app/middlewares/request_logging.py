import logging
from time import perf_counter
from typing import Any, Awaitable, Callable, cast
from uuid import uuid4

from fastapi import Request
from starlette.datastructures import MutableHeaders
from starlette.types import ASGIApp, Message, Receive, Scope, Send

from app.logging_context import reset_request_id, set_request_id

logger = logging.getLogger("app.request")


class RequestLoggingMiddleware:
    def __init__(self, app: ASGIApp):
        self.app = app

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        headers = MutableHeaders(scope=scope)
        request_id = headers.get("X-Request-ID") or uuid4().hex
        token = set_request_id(request_id)
        scope.setdefault("state", {})
        scope["state"]["request_id"] = request_id
        method = scope.get("method", "-")
        path = scope.get("path", "-")
        client = scope.get("client")
        client_host = client[0] if client else "-"
        status_code = 500
        start = perf_counter()

        async def send_wrapper(message: Message) -> None:
            nonlocal status_code
            if message["type"] == "http.response.start":
                status_code = int(message["status"])
                response_headers = MutableHeaders(scope=message)
                response_headers["X-Request-ID"] = request_id
            await send(message)

        try:
            await self.app(scope, receive, send_wrapper)
        except Exception as exc:
            app = cast(Any, scope.get("app"))
            exception_handlers = getattr(app, "exception_handlers", {})
            handler = cast(Callable[[Request, Exception], Awaitable[Any]] | None, exception_handlers.get(Exception))
            if handler is not None:
                request = Request(scope, receive)
                response = await handler(request, exc)
                response.headers["X-Request-ID"] = request_id
                duration_ms = (perf_counter() - start) * 1000
                status_code = response.status_code
                await response(scope, receive, send)
                logger.info(
                    "request_completed method=%s path=%s status_code=%s client=%s duration_ms=%.2f",
                    method,
                    path,
                    status_code,
                    client_host,
                    duration_ms,
                )
                reset_request_id(token)
                return

            duration_ms = (perf_counter() - start) * 1000
            logger.exception(
                "request_failed method=%s path=%s client=%s duration_ms=%.2f",
                method,
                path,
                client_host,
                duration_ms,
            )
            reset_request_id(token)
            raise

        duration_ms = (perf_counter() - start) * 1000
        logger.info(
            "request_completed method=%s path=%s status_code=%s client=%s duration_ms=%.2f",
            method,
            path,
            status_code,
            client_host,
            duration_ms,
        )
        reset_request_id(token)
