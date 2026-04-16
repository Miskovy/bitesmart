import logging
import traceback

from fastapi import Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.constants.ErrorCodes import ErrorCodes
from app.exceptions.AppException import AppException
from app.schemas.error import ErrorResponse

logger = logging.getLogger(__name__)


def error_response(
    status_code: int,
    error_code: str,
    message: str,
    path: str,
    details=None,
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
    logger.warning(f"[{exc.error_code}] {exc.message} | Path: {request.url.path}")
    return error_response(
        status_code=exc.status_code,
        error_code=exc.error_code,
        message=exc.message,
        path=request.url.path,
        details=exc.details,
    )


async def http_exception_handler(request: Request, exc: StarletteHTTPException):
    logger.warning(f"[HTTP {exc.status_code}] {exc.detail} | Path: {request.url.path}")
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
    logger.warning(f"[{ErrorCodes.VALIDATION_ERROR.name}] Path: {request.url.path} | Details: {details}")
    return error_response(
        status_code=ErrorCodes.VALIDATION_ERROR.status_code,
        error_code=ErrorCodes.VALIDATION_ERROR.name,
        message="Request validation failed",
        path=request.url.path,
        details=details,
    )


async def unhandled_exception_handler(request: Request, exc: Exception):
    logger.error(f"[UNHANDLED ERROR] {str(exc)} | Path: {request.url.path}\n{traceback.format_exc()}")
    return error_response(
        status_code=ErrorCodes.INTERNAL_ERROR.status_code,
        error_code=ErrorCodes.INTERNAL_ERROR.name,
        message="An unexpected error occurred",
        path=request.url.path,
    )
