from dataclasses import dataclass


@dataclass(frozen=True)
class ErrorCode:
    name: str
    status_code: int

    def as_dict(self) -> dict[str, int | str]:
        return {"name": self.name, "status_code": self.status_code}

    def __int__(self) -> int:
        return self.status_code

    def __str__(self) -> str:
        return self.name


class ErrorCodes:
    BAD_REQUEST = ErrorCode("BAD_REQUEST", 400)
    UNAUTHORIZED = ErrorCode("UNAUTHORIZED", 401)
    FORBIDDEN = ErrorCode("FORBIDDEN", 403)
    NOT_FOUND = ErrorCode("NOT_FOUND", 404)
    CONFLICT = ErrorCode("CONFLICT", 409)
    VALIDATION_ERROR = ErrorCode("VALIDATION_ERROR", 422)
    INTERNAL_ERROR = ErrorCode("INTERNAL_ERROR", 500)
    NOT_IMPLEMENTED = ErrorCode("NOT_IMPLEMENTED", 501)
    BAD_GATEWAY = ErrorCode("BAD_GATEWAY", 502)
    SERVICE_UNAVAILABLE = ErrorCode("SERVICE_UNAVAILABLE", 503)
    GATEWAY_TIMEOUT = ErrorCode("GATEWAY_TIMEOUT", 504)

    @classmethod
    def all(cls) -> tuple[ErrorCode, ...]:
        return (
            cls.BAD_REQUEST,
            cls.UNAUTHORIZED,
            cls.FORBIDDEN,
            cls.NOT_FOUND,
            cls.CONFLICT,
            cls.VALIDATION_ERROR,
            cls.INTERNAL_ERROR,
            cls.NOT_IMPLEMENTED,
            cls.BAD_GATEWAY,
            cls.SERVICE_UNAVAILABLE,
            cls.GATEWAY_TIMEOUT,
        )

    @classmethod
    def from_name(cls, name: str) -> ErrorCode:
        normalized_name = name.strip().upper()
        for error_code in cls.all():
            if error_code.name == normalized_name:
                return error_code
        raise ValueError(f"Unknown error code name: {name}")

    @classmethod
    def from_status_code(cls, status_code: int) -> ErrorCode:
        for error_code in cls.all():
            if error_code.status_code == status_code:
                return error_code
        raise ValueError(f"Unknown status code: {status_code}")
