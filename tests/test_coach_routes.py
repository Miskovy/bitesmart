from unittest.mock import AsyncMock

from app.constants.ErrorCodes import ErrorCodes
from app.constants.SuccessCodes import SuccessCodes
from app.exceptions.NotFound import NotFoundException
from app.schemas.coach import ChatSessionsData, CoachChatData, SessionOut


def test_chat_route_calls_service_and_returns_response(coach_api, monkeypatch):
    client, coach_router_module, fake_db = coach_api
    chat_mock = AsyncMock(
        return_value=CoachChatData(
            session_id="session-1",
            coach_response="Increase your protein at lunch.",
        )
    )
    monkeypatch.setattr(coach_router_module.coach_service, "chat_with_coach", chat_mock)

    response = client.post(
        "/api/coach/chat",
        json={"user_id": "user-1", "message": "What should I eat?", "session_id": "session-1"},
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["success_code"] == SuccessCodes.OK.name
    assert payload["message"] == "Coach reply generated successfully."
    assert payload["data"] == {
        "session_id": "session-1",
        "coach_response": "Increase your protein at lunch.",
    }

    kwargs = chat_mock.await_args.kwargs
    assert kwargs["db"] is fake_db
    assert kwargs["client"] is coach_router_module.client
    assert kwargs["user_id"] == "user-1"
    assert kwargs["message"] == "What should I eat?"
    assert kwargs["session_id"] == "session-1"


def test_chat_route_validates_required_body_fields(coach_api):
    client, _, _ = coach_api

    response = client.post("/api/coach/chat", json={"message": "Hello"})
    payload = response.json()

    assert response.status_code == 422
    assert payload["error_code"] == ErrorCodes.VALIDATION_ERROR.name
    assert payload["details"][0]["field"] == "body -> user_id"
    assert "Field required" in payload["details"][0]["message"]


def test_get_sessions_route_returns_service_payload(coach_api, monkeypatch):
    client, coach_router_module, fake_db = coach_api
    captured = {}

    def fake_list_user_sessions(db, user_id):
        captured.update({"db": db, "user_id": user_id})
        return ChatSessionsData(
            sessions=[
                SessionOut(
                    id="session-1",
                    title="Meal planning",
                    created_at="2026-04-16T10:00:00Z",
                    updated_at="2026-04-16T11:00:00Z",
                )
            ]
        )

    monkeypatch.setattr(coach_router_module.coach_service, "list_user_sessions", fake_list_user_sessions)

    response = client.get("/api/coach/sessions", params={"user_id": "user-1"})
    payload = response.json()

    assert response.status_code == 200
    assert payload["success_code"] == SuccessCodes.OK.name
    assert payload["data"]["sessions"][0]["id"] == "session-1"
    assert captured == {"db": fake_db, "user_id": "user-1"}


def test_get_history_route_returns_not_found_errors(coach_api, monkeypatch):
    client, coach_router_module, fake_db = coach_api

    def fake_get_session_history(db, session_id, user_id):
        assert db is fake_db
        assert session_id == "missing-session"
        assert user_id == "user-1"
        raise NotFoundException("Chat session", session_id)

    monkeypatch.setattr(coach_router_module.coach_service, "get_session_history", fake_get_session_history)

    response = client.get("/api/coach/sessions/missing-session/history", params={"user_id": "user-1"})
    payload = response.json()

    assert response.status_code == 404
    assert payload["error_code"] == ErrorCodes.NOT_FOUND.name
    assert payload["message"] == "Chat session not found: missing-session"
    assert payload["path"] == "/api/coach/sessions/missing-session/history"


def test_delete_session_route_returns_no_content(coach_api, monkeypatch):
    client, coach_router_module, fake_db = coach_api
    captured = {}

    def fake_delete_session(db, session_id, user_id):
        captured.update({"db": db, "session_id": session_id, "user_id": user_id})

    monkeypatch.setattr(coach_router_module.coach_service, "delete_session", fake_delete_session)

    response = client.delete("/api/coach/sessions/session-9", params={"user_id": "user-1"})

    assert response.status_code == 204
    assert response.content == b""
    assert captured == {"db": fake_db, "session_id": "session-9", "user_id": "user-1"}


def test_coach_routes_require_internal_auth_when_middleware_is_enabled(coach_protected_api):
    client, _, _ = coach_protected_api

    response = client.get("/api/coach/sessions", params={"user_id": "user-1"})
    payload = response.json()

    assert response.status_code == 401
    assert payload["error_code"] == ErrorCodes.UNAUTHORIZED.name
    assert payload["message"] == "Missing auth headers"
