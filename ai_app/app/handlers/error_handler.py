import logging
import traceback
from typing import Any

from fastapi import Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.constants.ErrorCodes import ErrorCodes
from app.exceptions.AppException import AppException
from app.schemas.error import ErrorResponse

logger = logging.getLogger("app.error")


def error_response(
    status_code: int,
    error_code: str,
    message: str,
    path: str,
    details: Any = None,
):
    return JSONResponse(
        status_code=status_code,
        content=ErrorResponse(
            status_code=status_code,
            error_code=error_code,
            message=message,
            details=details,
            path=path,
        ).model_dump(),
    )


async def app_exception_handler(request: Request, exc: AppException):
    logger.warning(
        "app_exception error_code=%s path=%s message=%s",
        exc.error_code,
        request.url.path,
        exc.message,
    )
    return error_response(
        status_code=exc.status_code,
        error_code=exc.error_code,
        message=exc.message,
        path=request.url.path,
        details=exc.details,
    )


async def http_exception_handler(request: Request, exc: StarletteHTTPException):
    logger.warning(
        "http_exception status_code=%s path=%s detail=%s",
        exc.status_code,
        request.url.path,
        exc.detail,
    )
    try:
        error_code = ErrorCodes.from_status_code(exc.status_code).name
    except ValueError:
        error_code = "HTTP_ERROR"

    return error_response(
        status_code=exc.status_code,
        error_code=error_code,
        message=str(exc.detail),
        path=request.url.path,
    )


async def validation_exception_handler(request: Request, exc: RequestValidationError):
    details = [
        {"field": " -> ".join(str(location) for location in err["loc"]), "message": err["msg"]}
        for err in exc.errors()
    ]
    logger.warning(
        "validation_exception path=%s details=%s",
        request.url.path,
        details,
    )
    return error_response(
        status_code=ErrorCodes.VALIDATION_ERROR.status_code,
        error_code=ErrorCodes.VALIDATION_ERROR.name,
        message="Request validation failed",
        path=request.url.path,
        details=details,
    )


async def unhandled_exception_handler(request: Request, exc: Exception):
    logger.error(
        "unhandled_exception path=%s error=%s\n%s",
        request.url.path,
        str(exc),
        traceback.format_exc(),
    )
    return error_response(
        status_code=ErrorCodes.INTERNAL_ERROR.status_code,
        error_code=ErrorCodes.INTERNAL_ERROR.name,
        message="An unexpected error occurred",
        path=request.url.path,
    )
