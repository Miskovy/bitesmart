from fastapi import Request
from fastapi.responses import FileResponse
from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint
from starlette.responses import Response


class NotFoundHTMLMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:
        response = await call_next(request)
        if response.status_code == 404:
            accept = request.headers.get("accept", "")
            if "text/html" in accept and "application/json" not in accept:
                return FileResponse("public/404.html", status_code=404)

        return response
