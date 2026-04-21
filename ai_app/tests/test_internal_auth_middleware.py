import time

from app.constants.ErrorCodes import ErrorCodes


def test_unprotected_paths_bypass_auth(middleware_client):
    assert middleware_client.get("/").status_code == 200
    assert middleware_client.get("/health").status_code == 200
    assert middleware_client.get("/health/data").status_code == 200
    assert middleware_client.get("/health/status").status_code == 200


def test_api_root_redirects_to_health_without_auth(middleware_client):
    response = middleware_client.get("/api", follow_redirects=False)

    assert response.status_code == 307
    assert response.headers["location"] == "/health"


def test_missing_routes_bypass_auth_and_return_not_found(middleware_client):
    response = middleware_client.get("/does-not-exist")

    assert response.status_code == 404


def test_missing_auth_headers_return_unauthorized(middleware_client):
    response = middleware_client.get("/protected")
    payload = response.json()

    assert response.status_code == 401
    assert payload["error_code"] == ErrorCodes.UNAUTHORIZED.name
    assert payload["message"] == "Missing auth headers"
    assert payload["path"] == "/protected"


def test_invalid_api_key_is_rejected(middleware_client, sign_request):
    headers = sign_request("/protected")
    headers["X-Api-Key"] = "wrong-key"

    response = middleware_client.get("/protected", headers=headers)

    assert response.status_code == 401
    assert response.json()["message"] == "Invalid API key"


def test_expired_timestamp_is_rejected(middleware_client, sign_request):
    timestamp_ms = int((time.time() - 120) * 1000)
    headers = sign_request("/protected", timestamp_ms=timestamp_ms)

    response = middleware_client.get("/protected", headers=headers)

    assert response.status_code == 401
    assert response.json()["message"] == "Request timestamp expired"


def test_valid_signature_allows_request_and_preserves_json_body(middleware_client, sign_request):
    body = b'{"meal":"salad","calories":320}'
    headers = sign_request("/echo", method="POST", body=body)
    headers["content-type"] = "application/json"

    response = middleware_client.post("/echo", content=body, headers=headers)

    assert response.status_code == 200
    assert response.json() == {"meal": "salad", "calories": 320}
