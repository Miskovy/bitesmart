from typing import Any

from app.constants.ErrorCodes import ErrorCodes
from app.exceptions.AppException import AppException


class ForbiddenException(AppException):
    def __init__(self, message: str = "Forbidden", details: Any = None):
        super().__init__(
            error=ErrorCodes.FORBIDDEN,
            message=message,
            details=details,
        )
