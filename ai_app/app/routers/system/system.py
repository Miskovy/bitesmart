from fastapi import APIRouter, Request
from fastapi.responses import FileResponse, RedirectResponse

from app.constants.ErrorCodes import ErrorCodes
from app.constants.SuccessCodes import SuccessCodes
from app.handlers.error_handler import error_response
from app.handlers.success_handler import success_response
from app.services.health_service import (
    build_liveness_payload,
    build_readiness_payload,
    get_health_snapshot,
)

router = APIRouter()


@router.get("/api", include_in_schema=False)
@router.get("/api/", include_in_schema=False)
async def api_root():
    return RedirectResponse(url="/health", status_code=307)


@router.get("/")
async def root():
    return success_response(
        SuccessCodes.OK,
        data={"message": "Welcome to Bitesmart Ai"},
        message="Root endpoint loaded successfully.",
    )


@router.get("/health/live", include_in_schema=False)
async def health_live(request: Request):
    return success_response(
        SuccessCodes.OK,
        data=build_liveness_payload(request.app),
        message="Liveness check completed successfully.",
    )


@router.get("/health/ready", include_in_schema=False)
async def health_ready(request: Request):
    payload = build_readiness_payload(request.app)
    if payload["ready"]:
        return success_response(
            SuccessCodes.OK,
            data=payload,
            message="Readiness check completed successfully.",
        )

    return error_response(
        ErrorCodes.SERVICE_UNAVAILABLE.status_code,
        ErrorCodes.SERVICE_UNAVAILABLE.name,
        "Application is not ready to serve requests.",
        request.url.path,
        details=payload,
    )


@router.get("/health/data", include_in_schema=False)
async def health_data(request: Request):
    return success_response(
        SuccessCodes.OK,
        data=get_health_snapshot(request.app),
        message="Dashboard health snapshot loaded successfully.",
    )


@router.get("/health")
async def health(request: Request):
    accept = request.headers.get("accept", "")
    if "text/html" in accept and "application/json" not in accept:
        return FileResponse("public/status.html")

    return await health_data(request)
