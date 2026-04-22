import hashlib
import hmac
import os
import sys
import time
import warnings
from pathlib import Path
from typing import Any

import pytest
from fastapi import Body, FastAPI, HTTPException
from fastapi.exceptions import RequestValidationError
from fastapi.responses import RedirectResponse
from fastapi.testclient import TestClient
from pydantic import BaseModel
from starlette.exceptions import HTTPException as StarletteHTTPException

PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

os.environ.setdefault("INTERNAL_API_KEY", "test-api-key")
os.environ.setdefault("INTERNAL_API_SECRET", "test-api-secret")
os.environ.setdefault("MYSQL_PASSWORD", "test-password")
os.environ.setdefault("GEMINI_API_KEY", "test-gemini-key")
warnings.filterwarnings("ignore", message=".*_UnionGenericAlias.*", category=DeprecationWarning)
warnings.filterwarnings("ignore", category=DeprecationWarning, module=r"google\.genai\.types")

from app.constants.ErrorCodes import ErrorCodes
from app.exceptions.AppException import AppException
from app.handlers.error_handler import (
    app_exception_handler,
    http_exception_handler,
    unhandled_exception_handler,
    validation_exception_handler,
)
from app.middlewares.auth import InternalAuthMiddleware

TEST_API_KEY = os.environ["INTERNAL_API_KEY"]
TEST_API_SECRET = os.environ["INTERNAL_API_SECRET"]


class NumberPayload(BaseModel):
    value: int


def build_signed_headers(
    path: str,
    method: str = "GET",
    body: bytes = b"",
    timestamp_ms: int | None = None,
    multipart: bool = False,
) -> dict[str, str]:
    timestamp_ms = timestamp_ms or int(time.time() * 1000)
    body_hash = hashlib.sha256(b"" if multipart else body).hexdigest()
    payload = f"{timestamp_ms}:{method.upper()}:{path}:{body_hash}"
    signature = hmac.new(
        TEST_API_SECRET.encode(),
        payload.encode(),
        hashlib.sha256,
    ).hexdigest()
    return {
        "X-Api-Key": TEST_API_KEY,
        "X-Signature": signature,
        "X-Timestamp": str(timestamp_ms),
    }


def _create_router_client(
    router,
    dependency,
    prefix: str,
    fake_db,
    include_auth: bool = False,
    state_values: dict[str, Any] | None = None,
):
    app = FastAPI()
    app.add_exception_handler(AppException, app_exception_handler)
    app.add_exception_handler(StarletteHTTPException, http_exception_handler)
    app.add_exception_handler(RequestValidationError, validation_exception_handler)
    app.add_exception_handler(Exception, unhandled_exception_handler)

    if include_auth:
        app.add_middleware(InternalAuthMiddleware)

    def override_get_db():
        yield fake_db

    if state_values:
        for key, value in state_values.items():
            setattr(app.state, key, value)

    app.dependency_overrides[dependency] = override_get_db
    app.include_router(router, prefix=prefix)
    return app


@pytest.fixture
def sign_request():
    return build_signed_headers


@pytest.fixture
def middleware_client():
    app = FastAPI()
    app.add_middleware(InternalAuthMiddleware)

    @app.get("/")
    async def root():
        return {"message": "public"}

    @app.get("/health")
    async def health():
        return {"status": "ok"}

    @app.get("/health/data")
    async def health_data():
        return {"status": "ok"}

    @app.get("/health/status")
    async def health_status():
        return {"status": "ok"}

    @app.get("/api")
    @app.get("/api/")
    async def api_root():
        return RedirectResponse(url="/health", status_code=307)

    @app.get("/protected")
    async def protected():
        return {"message": "secret"}

    @app.post("/echo")
    async def echo(payload: dict = Body(...)):
        return payload

    with TestClient(app) as client:
        yield client


@pytest.fixture
def fake_db():
    return object()


@pytest.fixture
def food_api(fake_db):
    from app.routers.food import food as food_router_module

    app = _create_router_client(
        router=food_router_module.router,
        dependency=food_router_module.get_db,
        prefix="/api/food",
        fake_db=fake_db,
    )

    with TestClient(app) as client:
        yield client, food_router_module, fake_db

    app.dependency_overrides.clear()


@pytest.fixture
def food_protected_api(fake_db):
    from app.routers.food import food as food_router_module

    app = _create_router_client(
        router=food_router_module.router,
        dependency=food_router_module.get_db,
        prefix="/api/food",
        fake_db=fake_db,
        include_auth=True,
    )

    with TestClient(app) as client:
        yield client, food_router_module, fake_db

    app.dependency_overrides.clear()


@pytest.fixture
def coach_api(fake_db):
    from app.routers.coach import coach as coach_router_module

    app = _create_router_client(
        router=coach_router_module.router,
        dependency=coach_router_module.get_db,
        prefix="/api/coach",
        fake_db=fake_db,
    )

    with TestClient(app) as client:
        yield client, coach_router_module, fake_db

    app.dependency_overrides.clear()


@pytest.fixture
def coach_protected_api(fake_db):
    from app.routers.coach import coach as coach_router_module

    app = _create_router_client(
        router=coach_router_module.router,
        dependency=coach_router_module.get_db,
        prefix="/api/coach",
        fake_db=fake_db,
        include_auth=True,
    )

    with TestClient(app) as client:
        yield client, coach_router_module, fake_db

    app.dependency_overrides.clear()


@pytest.fixture
def prediction_v3_api():
    from app.routers.prediction.v3 import prediction as prediction_v3_router_module

    app = FastAPI()
    app.add_exception_handler(AppException, app_exception_handler)
    app.add_exception_handler(StarletteHTTPException, http_exception_handler)
    app.add_exception_handler(RequestValidationError, validation_exception_handler)
    app.add_exception_handler(Exception, unhandled_exception_handler)
    app.add_middleware(InternalAuthMiddleware)
    app.include_router(prediction_v3_router_module.router, prefix="/api/v3")

    with TestClient(app) as client:
        yield client, prediction_v3_router_module

    app.dependency_overrides.clear()


@pytest.fixture
def prediction_v4_api(fake_db):
    from app.routers.prediction.v4 import prediction as prediction_v4_router_module

    app = _create_router_client(
        router=prediction_v4_router_module.router,
        dependency=prediction_v4_router_module.get_db,
        prefix="/api/v4",
        fake_db=fake_db,
        include_auth=True,
        state_values={
            "convnext_session": object(),
            "class_names": ["salad", "pizza"],
            "yolo_ar_model": object(),
        },
    )

    with TestClient(app) as client:
        yield client, prediction_v4_router_module, fake_db

    app.dependency_overrides.clear()


@pytest.fixture
def error_client():
    app = FastAPI()
    app.add_exception_handler(AppException, app_exception_handler)
    app.add_exception_handler(StarletteHTTPException, http_exception_handler)
    app.add_exception_handler(RequestValidationError, validation_exception_handler)
    app.add_exception_handler(Exception, unhandled_exception_handler)

    @app.get("/app-error")
    async def app_error():
        raise AppException(
            ErrorCodes.CONFLICT,
            "Duplicate resource",
            details={"id": 7},
        )

    @app.get("/http-error")
    async def http_error():
        raise HTTPException(status_code=404, detail="Missing resource")

    @app.post("/validation-error")
    async def validation_error(payload: NumberPayload):
        return payload.model_dump()

    @app.get("/unhandled-error")
    async def unhandled_error():
        raise RuntimeError("Unexpected failure")

    with TestClient(app, raise_server_exceptions=False) as client:
        yield client
