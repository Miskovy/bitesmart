from fastapi import FastAPI
from fastapi.testclient import TestClient

from app.constants.ErrorCodes import ErrorCodes
from app.constants.SuccessCodes import SuccessCodes
from app.routers.system.system import router as system_router
from app.services.health_service import initialize_health_state, mark_ready, refresh_health_snapshot


def create_system_client():
    app = FastAPI()
    initialize_health_state(app)
    app.include_router(system_router)
    return app, TestClient(app)


def test_health_live_returns_process_status():
    app, client = create_system_client()

    with client:
        response = client.get("/health/live")
        payload = response.json()

    assert response.status_code == 200
    assert payload["success_code"] == SuccessCodes.OK.name
    assert payload["data"]["status"] == "alive"
    assert payload["data"]["uptime_seconds"] >= 0


def test_health_ready_returns_service_unavailable_until_app_is_ready():
    app, client = create_system_client()

    with client:
        response = client.get("/health/ready")
        payload = response.json()

    assert response.status_code == 503
    assert payload["error_code"] == ErrorCodes.SERVICE_UNAVAILABLE.name
    assert payload["details"]["ready"] is False
    assert payload["details"]["status"] == "not_ready"


def test_health_ready_returns_ok_when_app_is_marked_ready():
    app, client = create_system_client()
    app.state.class_names = ["salad"]
    app.state.convnext_session = object()
    app.state.yolo_ar_model = object()
    mark_ready(app)

    with client:
        response = client.get("/health/ready")
        payload = response.json()

    assert response.status_code == 200
    assert payload["success_code"] == SuccessCodes.OK.name
    assert payload["data"]["ready"] is True
    assert payload["data"]["status"] == "ready"


def test_health_data_returns_cached_snapshot_until_refreshed():
    app, client = create_system_client()

    with client:
        first_response = client.get("/health/data")
        first_payload = first_response.json()

        app.state.convnext_session = object()

        cached_response = client.get("/health/data")
        cached_payload = cached_response.json()

        refresh_health_snapshot(app)
        refreshed_response = client.get("/health/data")
        refreshed_payload = refreshed_response.json()

    assert first_response.status_code == 200
    assert first_payload["data"]["model_loaded"] is False
    assert cached_payload["data"]["model_loaded"] is False
    assert refreshed_payload["data"]["model_loaded"] is True
