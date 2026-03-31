from typing import Any

from app.constants.ErrorCodes import ErrorCodes
from app.exceptions.AppException import AppException


class UnauthorizedException(AppException):
    def __init__(self, message: str = "Unauthorized", details: Any = None):
        super().__init__(
            error=ErrorCodes.UNAUTHORIZED,
            message=message,
            details=details,
        )
