from fastapi import FastAPI, Request
from fastapi.testclient import TestClient

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
