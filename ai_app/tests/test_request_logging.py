from fastapi import FastAPI, Request
from fastapi.testclient import TestClient

from app.handlers.error_handler import unhandled_exception_handler
from app.middlewares.request_logging import RequestLoggingMiddleware


def create_logging_client():
    app = FastAPI()
    app.add_middleware(RequestLoggingMiddleware)

    @app.get("/ping")
    async def ping(request: Request):
        return {"request_id": request.state.request_id}

    return TestClient(app)


def test_request_logging_generates_request_id_header():
    with create_logging_client() as client:
        response = client.get("/ping")

    assert response.status_code == 200
    assert response.headers["X-Request-ID"]
    assert response.json()["request_id"] == response.headers["X-Request-ID"]


def test_request_logging_preserves_incoming_request_id():
    request_id = "test-request-id-123"

    with create_logging_client() as client:
        response = client.get("/ping", headers={"X-Request-ID": request_id})

    assert response.status_code == 200
    assert response.headers["X-Request-ID"] == request_id
    assert response.json()["request_id"] == request_id


def test_request_logging_adds_request_id_header_on_error_response():
    app = FastAPI()
    app.add_middleware(RequestLoggingMiddleware)
    app.add_exception_handler(Exception, unhandled_exception_handler)

    @app.get("/boom")
    async def boom():
        raise RuntimeError("boom")

    with TestClient(app, raise_server_exceptions=False) as client:
        response = client.get("/boom")

    assert response.status_code == 500
    assert response.headers["X-Request-ID"]
