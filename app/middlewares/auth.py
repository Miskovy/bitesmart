import hashlib
import hmac
import time
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
from app.config.config import settings
from app.handlers.error_handler import error_response

UNPROTECTED_PATHS = {"/", "/health", "/docs", "/openapi.json", "/redoc"}
UNPROTECTED_PREFIXES = ("/api/food",)

class InternalAuthMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):

        if request.url.path in UNPROTECTED_PATHS or request.url.path.startswith(UNPROTECTED_PREFIXES):
            return await call_next(request)

        api_key   = request.headers.get("X-Api-Key")
        signature = request.headers.get("X-Signature")
        timestamp = request.headers.get("X-Timestamp")

        if not all([api_key, signature, timestamp]):
            return error_response(401, "UNAUTHORIZED", "Missing auth headers", request.url.path)

        if not hmac.compare_digest(api_key, settings.INTERNAL_API_KEY):
            return error_response(401, "UNAUTHORIZED", "Invalid API key", request.url.path)

        try:
            request_time = int(timestamp) / 1000
            if abs(time.time() - request_time) > settings.ALLOWED_TIMESTAMP_DRIFT_SECONDS:
                return error_response(401, "UNAUTHORIZED", "Request timestamp expired", request.url.path)
        except ValueError:
            return error_response(401, "UNAUTHORIZED", "Invalid timestamp format", request.url.path)

        content_type = request.headers.get("content-type", "")

        if "multipart/form-data" in content_type:
            # File uploads — hash empty string, body is re-read by FastAPI
            body_hash = hashlib.sha256(b"").hexdigest()
        else:
            # JSON / form-urlencoded — hash the actual body
            body = await request.body()
            body_hash = hashlib.sha256(body).hexdigest()

            # Re-inject body so the route handler can still read it
            async def receive():
                return {"type": "http.request", "body": body}
            request._receive = receive

        payload = f"{timestamp}:{request.method}:{request.url.path}:{body_hash}"

        expected_sig = hmac.new(
            settings.INTERNAL_API_SECRET.encode(),
            payload.encode(),
            hashlib.sha256
        ).hexdigest()

        if not hmac.compare_digest(signature, expected_sig):
            return error_response(401, "UNAUTHORIZED", "Invalid signature", request.url.path)

        return await call_next(request)
