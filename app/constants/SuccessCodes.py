from dataclasses import dataclass


@dataclass(frozen=True)
class SuccessCode:
    name: str
    status_code: int
    default_message: str

    def as_dict(self) -> dict[str, int | str]:
        return {
            "name": self.name,
            "status_code": self.status_code,
            "default_message": self.default_message,
        }

    def __int__(self) -> int:
        return self.status_code

    def __str__(self) -> str:
        return self.name


class SuccessCodes:
    OK = SuccessCode("OK", 200, "Request completed successfully.")
    CREATED = SuccessCode("CREATED", 201, "Resource created successfully.")
    NON_AUTHORITATIVE_INFORMATION = SuccessCode(
        "NON_AUTHORITATIVE_INFORMATION",
        203,
        "Request completed with transformed or additional metadata.",
    )
    NO_CONTENT = SuccessCode("NO_CONTENT", 204, "Request completed successfully.")

    @classmethod
    def all(cls) -> tuple[SuccessCode, ...]:
        return (
            cls.OK,
            cls.CREATED,
            cls.NON_AUTHORITATIVE_INFORMATION,
            cls.NO_CONTENT,
        )

    @classmethod
    def from_name(cls, name: str) -> SuccessCode:
        normalized_name = name.strip().upper()
        for success_code in cls.all():
            if success_code.name == normalized_name:
                return success_code
        raise ValueError(f"Unknown success code name: {name}")

    @classmethod
    def from_status_code(cls, status_code: int) -> SuccessCode:
        for success_code in cls.all():
            if success_code.status_code == status_code:
                return success_code
        raise ValueError(f"Unknown success status code: {status_code}")
