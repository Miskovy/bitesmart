from typing import Any

from app.constants.ErrorCodes import ErrorCodes
from app.exceptions.AppException import AppException


class ConflictException(AppException):
    def __init__(self, message: str, details: Any = None):
        super().__init__(
            error=ErrorCodes.CONFLICT,
            message=message,
            details=details,
        )
