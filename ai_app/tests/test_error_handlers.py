from app.constants.ErrorCodes import ErrorCodes


def test_app_exception_handler_returns_structured_error(error_client):
    response = error_client.get("/app-error")

    assert response.status_code == 409
    assert response.json() == {
        "success": False,
        "status_code": 409,
        "error_code": ErrorCodes.CONFLICT.name,
        "message": "Duplicate resource",
        "details": {"id": 7},
        "path": "/app-error",
        "timestamp": response.json()["timestamp"],
    }


def test_http_exception_handler_maps_status_codes(error_client):
    response = error_client.get("/http-error")
    payload = response.json()

    assert response.status_code == 404
    assert payload["error_code"] == ErrorCodes.NOT_FOUND.name
    assert payload["message"] == "Missing resource"
    assert payload["path"] == "/http-error"


def test_validation_exception_handler_includes_field_details(error_client):
    response = error_client.post("/validation-error", json={"value": "bad"})
    payload = response.json()

    assert response.status_code == 422
    assert payload["error_code"] == ErrorCodes.VALIDATION_ERROR.name
    assert payload["message"] == "Request validation failed"
    assert payload["details"] == [
        {"field": "body -> value", "message": "Input should be a valid integer, unable to parse string as an integer"}
    ]


def test_unhandled_exception_handler_masks_internal_errors(error_client):
    response = error_client.get("/unhandled-error")
    payload = response.json()

    assert response.status_code == 500
    assert payload["error_code"] == ErrorCodes.INTERNAL_ERROR.name
    assert payload["message"] == "An unexpected error occurred"
    assert payload["path"] == "/unhandled-error"
