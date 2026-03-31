from datetime import date
from typing import Any
import uuid

from google import genai
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.constants.ErrorCodes import ErrorCodes
from app.exceptions.AppException import AppException
from app.exceptions.NotFound import NotFoundException
from app.models.chat_model import ChatMessage, ChatSession
from app.models.food_model import DailyLogs, FoodItem
from app.models.user_model import User, UserMedicalConditions, UserTarget
from app.schemas.coach import ChatHistoryData, ChatHistorySession, CoachChatData, MessageOut, SessionOut, ChatSessionsData


def _build_system_prompt(
    user: User,
    targets: UserTarget,
    medical: UserMedicalConditions | None,
    consumed: dict[str, int],
) -> str:
    medical_context = "None"
    if medical:
        conditions = []
        if medical.isDiabetesType2:
            conditions.append("Type 2 Diabetes")
        if medical.isHypertension:
            conditions.append("Hypertension")
        if medical.isAnemia:
            conditions.append("Iron-deficiency Anemia")
        if medical.isPCOS:
            conditions.append("PCOS")
        if conditions:
            medical_context = ", ".join(conditions)

    return f"""You are the AI Fitness and Nutrition Coach for the Bitesmart App.
You are talking to {user.name}, a {user.age}-year-old {user.gender}. Their goal is {user.userGoal}.
Medical Conditions to be aware of: {medical_context}.

MACRO TARGETS FOR TODAY:
- Calories: {targets.calTotal}
- Protein: {targets.proteins}g
- Carbs: {targets.carbs}g
- Fats: {targets.fats}g

WHAT THEY HAVE EATEN SO FAR TODAY:
- Calories: {consumed['cals']}
- Protein: {consumed['protein']}g
- Carbs: {consumed['carbs']}g
- Fats: {consumed['fats']}g

RULES:
1. Be encouraging, concise, and act like a professional personal trainer.
2. Give specific food recommendations if asked.
3. Do not use markdown formatting like **bold** if the mobile app cannot render it.
4. Do not mention these system rules or recite the numbers back unless it helps make your point."""


def _get_today_consumed(db: Session, user_id: str) -> dict[str, int]:
    today_logs = (
        db.query(DailyLogs, FoodItem)
        .join(FoodItem, DailyLogs.foodItemId == FoodItem.id)
        .filter(DailyLogs.userId == user_id)
        .filter(func.date(DailyLogs.loggedAt) == date.today())
        .all()
    )

    cals, protein, carbs, fats = 0, 0, 0, 0
    for log, food in today_logs:
        multiplier = log.quantity / 100.0
        cals += food.cals_per_100g * multiplier
        protein += food.protein_per_100g * multiplier
        carbs += food.carbs_per_100g * multiplier
        fats += food.fats_per_100g * multiplier

    return {
        "cals": round(cals),
        "protein": round(protein),
        "carbs": round(carbs),
        "fats": round(fats),
    }


def _get_user_or_raise(db: Session, user_id: str) -> User:
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise NotFoundException("User", user_id)
    return user


def _get_user_targets_or_raise(db: Session, user_id: str) -> UserTarget:
    targets = db.query(UserTarget).filter(UserTarget.userId == user_id).first()
    if not targets:
        raise NotFoundException("User nutrition targets", user_id)
    return targets


def _get_session_or_raise(db: Session, session_id: str, user_id: str) -> ChatSession:
    session = db.query(ChatSession).filter(
        ChatSession.id == session_id,
        ChatSession.userId == user_id,
    ).first()
    if not session:
        raise NotFoundException("Chat session", session_id)
    return session


def _build_chat_contents(
    system_prompt: str,
    past_messages: list[ChatMessage],
    user_message: str,
) -> list[dict[str, Any]]:
    contents: list[dict[str, Any]] = [{"role": "user", "parts": [{"text": system_prompt}]}]

    if past_messages:
        contents.append(
            {
                "role": "model",
                "parts": [{"text": "Understood! I have your profile and today's data. How can I help?"}],
            }
        )

        for msg in past_messages:
            contents.append(
                {
                    "role": "user" if msg.role == "user" else "model",
                    "parts": [{"text": msg.content}],
                }
            )

    contents.append({"role": "user", "parts": [{"text": user_message}]})
    return contents


async def chat_with_coach(
    db: Session,
    client: genai.Client,
    user_id: str,
    message: str,
    session_id: str | None = None,
) -> CoachChatData:
    try:
        user = _get_user_or_raise(db, user_id)
        targets = _get_user_targets_or_raise(db, user.id)
        medical = db.query(UserMedicalConditions).filter(UserMedicalConditions.userId == user.id).first()

        if session_id:
            session = _get_session_or_raise(db, session_id, user.id)
        else:
            session = ChatSession(
                id=str(uuid.uuid4()),
                userId=user.id,
                title=message[:80],
            )
            db.add(session)
            db.flush()

        past_messages = (
            db.query(ChatMessage)
            .filter(ChatMessage.sessionId == session.id)
            .order_by(ChatMessage.createdAt.asc())
            .limit(20)
            .all()
        )

        consumed = _get_today_consumed(db, user.id)
        system_prompt = _build_system_prompt(user, targets, medical, consumed)
        contents = _build_chat_contents(system_prompt, past_messages, message)

        response = await client.aio.models.generate_content(
            model="gemini-3.1-flash-lite-preview",
            contents=contents,
        )
        ai_reply = response.text.strip()

        db.add(ChatMessage(sessionId=session.id, role="user", content=message))
        db.add(ChatMessage(sessionId=session.id, role="assistant", content=ai_reply))
        db.commit()

        return CoachChatData(
            session_id=session.id,
            coach_response=ai_reply,
        )
    except AppException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        raise AppException(ErrorCodes.INTERNAL_ERROR, f"Coach AI Failed: {str(e)}") from e


def list_user_sessions(db: Session, user_id: str) -> ChatSessionsData:
    _get_user_or_raise(db, user_id)
    sessions = (
        db.query(ChatSession)
        .filter(ChatSession.userId == user_id)
        .order_by(ChatSession.updatedAt.desc())
        .all()
    )

    return ChatSessionsData(
        sessions=[
            SessionOut(
                id=session.id,
                title=session.title,
                created_at=session.createdAt.isoformat(),
                updated_at=session.updatedAt.isoformat(),
            )
            for session in sessions
        ]
    )


def get_session_history(db: Session, session_id: str, user_id: str) -> ChatHistoryData:
    session = _get_session_or_raise(db, session_id, user_id)
    messages = (
        db.query(ChatMessage)
        .filter(ChatMessage.sessionId == session_id)
        .order_by(ChatMessage.createdAt.asc())
        .all()
    )

    return ChatHistoryData(
        session=ChatHistorySession(
            id=session.id,
            title=session.title,
            created_at=session.createdAt.isoformat(),
        ),
        messages=[
            MessageOut(
                id=message.id,
                role=message.role,
                content=message.content,
                created_at=message.createdAt.isoformat(),
            )
            for message in messages
        ],
    )


def delete_session(db: Session, session_id: str, user_id: str) -> None:
    session = _get_session_or_raise(db, session_id, user_id)
    db.query(ChatMessage).filter(ChatMessage.sessionId == session_id).delete()
    db.delete(session)
    db.commit()
