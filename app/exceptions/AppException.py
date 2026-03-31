from typing import Any

from app.constants.ErrorCodes import ErrorCode


class AppException(Exception):
    def __init__(self, error: ErrorCode, message: str, details: Any = None):
        self.error = error
        self.status_code = error.status_code
        self.error_code = error.name
        self.message = message
        self.details = details
        super().__init__(message)

    def to_dict(self) -> dict[str, Any]:
        return {
            "status_code": self.status_code,
            "error_code": self.error_code,
            "message": self.message,
            "details": self.details,
        }
