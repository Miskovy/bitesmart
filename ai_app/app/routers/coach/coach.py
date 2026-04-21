from fastapi import APIRouter, Depends, Query, status
from google import genai
from sqlalchemy.orm import Session
from sse_starlette.sse import EventSourceResponse

from app.config.config import settings
from app.constants.SuccessCodes import SuccessCodes
from app.db.database import get_db
from app.handlers.success_handler import success_response
from app.schemas.coach import ChatHistoryData, ChatSessionsData, CoachChatData, CoachChatRequest
from app.schemas.success import SuccessResponse
from app.services import coach_service

client = genai.Client(api_key=settings.GEMINI_API_KEY)

router = APIRouter()


@router.post("/chat", response_model=SuccessResponse[CoachChatData])
async def chat_with_coach(request: CoachChatRequest, db: Session = Depends(get_db)):
    """Standard (non-streaming) chat endpoint. Returns the full response at once."""
    result = await coach_service.chat_with_coach(
        db=db,
        client=client,
        user_id=request.user_id,
        message=request.message,
        session_id=request.session_id,
    )
    return success_response(
        SuccessCodes.OK,
        data=result.model_dump(),
        message="Coach reply generated successfully.",
    )


@router.post("/chat/stream")
async def chat_with_coach_stream(request: CoachChatRequest, db: Session = Depends(get_db)):
    """
    Streaming chat endpoint via Server-Sent Events (SSE).

    Events emitted:
      1. {"event": "session", "data": {"session_id": "..."}}   — sent first
      2. {"event": "token",   "data": {"token": "..."}}         — each text chunk
      3. {"event": "done",    "data": {"full_response": "..."}} — final message

    Mobile/web client usage:
      const es = new EventSource('/api/coach/chat/stream', { method: 'POST', body: ... });
      es.onmessage = (e) => { const data = JSON.parse(e.data); ... };
    """
    return EventSourceResponse(
        coach_service.chat_with_coach_stream(
            db=db,
            client=client,
            user_id=request.user_id,
            message=request.message,
            session_id=request.session_id,
        )
    )


@router.get("/sessions", response_model=SuccessResponse[ChatSessionsData])
async def get_user_sessions(
    user_id: str = Query(..., description="The user's UUID"),
    db: Session = Depends(get_db),
):
    result = coach_service.list_user_sessions(db, user_id)
    return success_response(
        SuccessCodes.OK,
        data=result.model_dump(),
        message="Chat sessions loaded successfully.",
    )


@router.get("/sessions/{session_id}/history", response_model=SuccessResponse[ChatHistoryData])
async def get_session_history(
    session_id: str,
    user_id: str = Query(..., description="The user's UUID"),
    db: Session = Depends(get_db),
):
    result = coach_service.get_session_history(db, session_id, user_id)
    return success_response(
        SuccessCodes.OK,
        data=result.model_dump(),
        message="Chat history loaded successfully.",
    )


@router.delete("/sessions/{session_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_session(
    session_id: str,
    user_id: str = Query(..., description="The user's UUID"),
    db: Session = Depends(get_db),
):
    coach_service.delete_session(db, session_id, user_id)
    return success_response(SuccessCodes.NO_CONTENT)

