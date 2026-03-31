from typing import Optional

from pydantic import BaseModel


class CoachChatRequest(BaseModel):
    user_id: str
    message: str
    session_id: Optional[str] = None


class CoachChatData(BaseModel):
    session_id: str
    coach_response: str


class SessionOut(BaseModel):
    id: str
    title: Optional[str]
    created_at: str
    updated_at: str


class ChatSessionsData(BaseModel):
    sessions: list[SessionOut]


class ChatHistorySession(BaseModel):
    id: str
    title: Optional[str]
    created_at: str


class MessageOut(BaseModel):
    id: str
    role: str
    content: str
    created_at: str


class ChatHistoryData(BaseModel):
    session: ChatHistorySession
    messages: list[MessageOut]
