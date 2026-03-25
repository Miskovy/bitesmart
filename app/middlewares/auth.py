import hashlib
import hmac
import time
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import JSONResponse
from app.config.config import settings

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
            return JSONResponse(
                status_code=401,
                content={"success": False, "error": {"code": 401, "message": "Missing auth headers"}}
            )

        if not hmac.compare_digest(api_key, settings.INTERNAL_API_KEY):
            return JSONResponse(
                status_code=401,
                content={"success": False, "error": {"code": 401, "message": "Invalid API key"}}
            )

        try:
            request_time = int(timestamp) / 1000
            if abs(time.time() - request_time) > settings.ALLOWED_TIMESTAMP_DRIFT_SECONDS:
                return JSONResponse(
                    status_code=401,
                    content={"success": False, "error": {"code": 401, "message": "Request timestamp expired"}}
                )
        except ValueError:
            return JSONResponse(
                status_code=401,
                content={"success": False, "error": {"code": 401, "message": "Invalid timestamp format"}}
            )

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
            return JSONResponse(
                status_code=401,
                content={"success": False, "error": {"code": 401, "message": "Invalid signature"}}
            )

        return await call_next(request)
