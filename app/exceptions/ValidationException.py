from typing import Any

from app.constants.ErrorCodes import ErrorCodes
from app.exceptions.AppException import AppException


class ValidationException(AppException):
    def __init__(self, resource: str, identifier: Any = None, details: Any = None):
        message = f"{resource} not valid"
        if identifier is not None:
            message += f": {identifier}"

        super().__init__(
            error=ErrorCodes.VALIDATION_ERROR,
            message=message,
            details=details,
        )
