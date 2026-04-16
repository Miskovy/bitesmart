import uuid

from sqlalchemy import Column, DateTime, ForeignKey, String, Text, func
from sqlalchemy.orm import relationship

from app.db.database import Base


class ChatSession(Base):
    __tablename__ = "chat_sessions"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    userId = Column(String(36), ForeignKey("users.id"), nullable=False, index=True)
    title = Column(String(255), nullable=True)
    createdAt = Column(DateTime, nullable=False, default=func.now())
    updatedAt = Column(DateTime, nullable=False, default=func.now(), onupdate=func.now())

    user = relationship("User")
    messages = relationship("ChatMessage", back_populates="session", order_by="ChatMessage.createdAt")


class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    sessionId = Column(String(36), ForeignKey("chat_sessions.id"), nullable=False, index=True)
    role = Column(String(10), nullable=False)
    content = Column(Text(), nullable=False)
    createdAt = Column(DateTime, nullable=False, default=func.now())

    session = relationship("ChatSession", back_populates="messages")
