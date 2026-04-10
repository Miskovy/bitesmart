from typing import Any

from fastapi import Response
from fastapi.responses import JSONResponse

from app.constants.SuccessCodes import SuccessCode
from app.schemas.success import SuccessResponse


def success_response(
    success: SuccessCode,
    data: Any = None,
    message: str | None = None,
):
    if success.status_code == 204:
        return Response(status_code=success.status_code)

    return JSONResponse(
        status_code=success.status_code,
        content=SuccessResponse(
            status_code=success.status_code,
            success_code=success.name,
            message=message or success.default_message,
            data=data,
        ).model_dump(),
    )
