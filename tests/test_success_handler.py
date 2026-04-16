import json

from app.constants.SuccessCodes import SuccessCodes
from app.handlers.success_handler import success_response


def test_success_response_uses_default_message_and_wraps_payload():
    response = success_response(SuccessCodes.OK, data={"message": "pong"})
    payload = json.loads(response.body)

    assert response.status_code == 200
    assert payload["success"] is True
    assert payload["success_code"] == SuccessCodes.OK.name
    assert payload["message"] == SuccessCodes.OK.default_message
    assert payload["data"] == {"message": "pong"}


def test_success_response_returns_empty_body_for_no_content():
    response = success_response(SuccessCodes.NO_CONTENT)

    assert response.status_code == 204
    assert response.body == b""
