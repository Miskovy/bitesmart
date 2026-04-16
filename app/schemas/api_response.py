from datetime import datetime, timezone
from typing import Any, Generic, TypeVar

from pydantic import BaseModel, Field

T = TypeVar("T")

class SuccessResponse(BaseModel, Generic[T]):
    success: bool = True
    status_code: int
    success_code: str
    message: str
    data: T | None = None
    timestamp: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())


class ErrorResponse(BaseModel):
    success: bool = False
    status_code: int
    error_code: str
    message: str
    details: Any | None = None
    path: str | None = None
    timestamp: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
