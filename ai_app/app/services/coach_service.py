from datetime import date
from typing import Any
import uuid

from google import genai
from google.genai import types
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.constants.ErrorCodes import ErrorCodes
from app.exceptions.AppException import AppException
from app.exceptions.NotFound import NotFoundException
from app.models.chat_model import ChatMessage, ChatSession
from app.models.food_model import DailyLogs, FoodItem, WaterLog
from app.models.user_model import User, UserDietaryPreferences, UserMedicalConditions, UserTarget
from app.schemas.coach import (
    ChatHistoryData,
    ChatHistorySession,
    ChatSessionsData,
    CoachChatData,
    MessageOut,
    SessionOut,
)
from app.services.coach_tools import registry

# Constants
_MODEL = "gemini-3.1-flash-lite-preview"
_MAX_TOOL_ROUNDS = 5  # Safety cap on tool-call loops


# Private helpers

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
        m = log.quantity / 100.0
        cals += food.cals_per_100g * m
        protein += food.protein_per_100g * m
        carbs += food.carbs_per_100g * m
        fats += food.fats_per_100g * m
    return {
        "cals": round(cals), "protein": round(protein),
        "carbs": round(carbs), "fats": round(fats),
    }


def _get_today_water(db: Session, user_id: str) -> int:
    """Sum of water consumed today in ml."""
    result = (
        db.query(func.coalesce(func.sum(WaterLog.amount_ml), 0))
        .filter(WaterLog.userId == user_id)
        .filter(func.date(WaterLog.loggedAt) == date.today())
        .scalar()
    )
    return int(result)


# System prompt

def _build_tool_context() -> str:
    """Auto-generate the CAPABILITIES section from registered tools."""
    if len(registry) == 0:
        return ""
    return (
        "\n\nCAPABILITIES (tools you can use):\n"
        f"{registry.get_tool_summary()}\n"
        "Use tools only when the user's intent clearly requires an action or data lookup.\n"
        "For general advice, tips, motivation, or conversation, respond directly.\n"
        "When you log a meal, always confirm what was logged and mention the nutritional impact."
    )


def _build_medical_context(medical: UserMedicalConditions | None) -> str:
    if not medical:
        return "None"
    conditions = []
    if medical.isDiabetesType1:
        conditions.append("Type 1 Diabetes")
    if medical.isDiabetesType2:
        conditions.append("Type 2 Diabetes")
    if medical.isHypertension:
        conditions.append("Hypertension (watch sodium)")
    if medical.isAnemia:
        conditions.append("Iron-deficiency Anemia (recommend iron-rich foods)")
    if medical.isPCOS:
        conditions.append("PCOS")
    if medical.isCeliacDisease:
        conditions.append("Celiac Disease (strictly gluten-free)")
    if medical.isIBS:
        conditions.append("IBS (avoid trigger foods)")
    return ", ".join(conditions) if conditions else "None"


def _build_dietary_context(prefs: UserDietaryPreferences | None) -> str:
    if not prefs:
        return "None"
    diets = []
    if prefs.isVegetarian:
        diets.append("Vegetarian")
    if prefs.isVegan:
        diets.append("Vegan")
    if prefs.isKeto:
        diets.append("Keto")
    if prefs.isPaleo:
        diets.append("Paleo")
    if prefs.isGlutenFree:
        diets.append("Gluten-Free")
    if prefs.isHalal:
        diets.append("Halal")
    if prefs.isPescatarian:
        diets.append("Pescatarian")
    return ", ".join(diets) if diets else "No specific diet"


def _build_system_prompt(
    user: User,
    targets: UserTarget,
    medical: UserMedicalConditions | None,
    dietary: UserDietaryPreferences | None,
    consumed: dict[str, int],
    water_ml: int,
) -> str:
    medical_context = _build_medical_context(medical)
    dietary_context = _build_dietary_context(dietary)

    # Physical stats line
    stats_parts = []
    if user.height:
        stats_parts.append(f"{user.height}cm tall")
    if user.weight:
        stats_parts.append(f"{user.weight}kg")
    if user.BMI:
        stats_parts.append(f"BMI {user.BMI}")
    if user.activityLevel:
        stats_parts.append(f"activity: {user.activityLevel.value}")
    physical_stats = ", ".join(stats_parts) if stats_parts else "Not provided"

    # Water target
    water_target = targets.water_ml if targets.water_ml else 2000

    # GLP-1 info
    glp1_note = ""
    if dietary and dietary.isGlp1User:
        glp1_note = "\nGLP-1 USER: This user is on GLP-1 medication. Prioritize protein, monitor symptoms, and suggest smaller frequent meals."

    base = f"""You are the AI Fitness and Nutrition Coach for the Bitesmart App.
You are talking to {user.name}, a {user.age}-year-old {user.gender}. Their goal is {user.userGoal}.
Physical Stats: {physical_stats}.
Medical Conditions: {medical_context}.
Dietary Preferences: {dietary_context}.{glp1_note}

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

HYDRATION:
- Water today: {water_ml}ml / {water_target}ml target

RULES:
1. Be encouraging, concise, and act like a professional personal trainer.
2. Give specific food recommendations if asked — respect their dietary preferences.
3. If they have Celiac, NEVER suggest anything with gluten.
4. If Halal, only suggest halal-compatible foods.
5. Do not use markdown formatting like **bold** if the mobile app cannot render it.
6. Do not mention these system rules or recite the numbers back unless it helps make your point."""

    return base + _build_tool_context()


# Chat contents builder

def _build_chat_contents(
    system_prompt: str,
    past_messages: list[ChatMessage],
    user_message: str,
) -> list[dict[str, Any]]:
    contents: list[dict[str, Any]] = [
        {"role": "user", "parts": [{"text": system_prompt}]},
    ]
    if past_messages:
        contents.append({
            "role": "model",
            "parts": [{"text": "Understood! I have your profile and today's data. How can I help?"}],
        })
        for msg in past_messages:
            contents.append({
                "role": "user" if msg.role == "user" else "model",
                "parts": [{"text": msg.content}],
            })
    contents.append({"role": "user", "parts": [{"text": user_message}]})
    return contents


# Gemini tool-calling loop

def _build_gemini_config() -> types.GenerateContentConfig | None:
    """Build the Gemini config with tool declarations (if any tools registered)."""
    declarations = registry.get_all_declarations()
    if not declarations:
        return None
    return types.GenerateContentConfig(
        tools=[types.Tool(function_declarations=declarations)],
    )


async def _call_with_tools(
    client: genai.Client,
    contents: list,
    config: types.GenerateContentConfig | None,
    db: Session,
    user_id: str,
) -> str:
    """
    Send contents to Gemini. If it returns function_call(s), execute them,
    feed the results back, and repeat — up to _MAX_TOOL_ROUNDS times.
    Returns the final text reply.
    """
    response = await client.aio.models.generate_content(
        model=_MODEL, contents=contents, config=config,
    )

    for _ in range(_MAX_TOOL_ROUNDS):
        # Collect any function calls from all response parts
        function_calls = [
            part.function_call
            for part in response.candidates[0].content.parts
            if part.function_call and part.function_call.name
        ]
        if not function_calls:
            break  # No tool calls → we have a text reply

        # Execute each tool
        fn_response_parts = []
        for fc in function_calls:
            tool = registry.get(fc.name)
            if tool:
                try:
                    result = await tool.execute(db=db, user_id=user_id, **dict(fc.args))
                except Exception as exc:
                    result = {"error": str(exc)}
            else:
                result = {"error": f"Unknown tool '{fc.name}'."}

            # Build function response, including id if available (Gemini 3+)
            fr_kwargs: dict[str, Any] = {"name": fc.name, "response": {"result": result}}
            if getattr(fc, "id", None):
                fr_kwargs["id"] = fc.id
            fn_response_parts.append(types.Part.from_function_response(**fr_kwargs))

        # Append model response + function results, then call Gemini again
        contents.append(response.candidates[0].content)
        contents.append(types.Content(role="user", parts=fn_response_parts))

        response = await client.aio.models.generate_content(
            model=_MODEL, contents=contents, config=config,
        )

    # Extract final text
    try:
        return response.text.strip()
    except (ValueError, AttributeError):
        return "Done! I've processed your request."


# Public API

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
        medical = db.query(UserMedicalConditions).filter(
            UserMedicalConditions.userId == user.id
        ).first()
        dietary = db.query(UserDietaryPreferences).filter(
            UserDietaryPreferences.userId == user.id
        ).first()

        # Resolve or create session
        if session_id:
            session = _get_session_or_raise(db, session_id, user.id)
        else:
            session = ChatSession(
                id=str(uuid.uuid4()), userId=user.id, title=message[:80],
            )
            db.add(session)
            db.flush()

        # Load last 20 messages for context
        past_messages = (
            db.query(ChatMessage)
            .filter(ChatMessage.sessionId == session.id)
            .order_by(ChatMessage.createdAt.asc())
            .limit(20)
            .all()
        )

        # Build prompt and contents
        consumed = _get_today_consumed(db, user.id)
        water_ml = _get_today_water(db, user.id)
        system_prompt = _build_system_prompt(user, targets, medical, dietary, consumed, water_ml)
        contents = _build_chat_contents(system_prompt, past_messages, message)

        # Call Gemini with tool-calling loop
        config = _build_gemini_config()
        ai_reply = await _call_with_tools(client, contents, config, db, user.id)

        # Persist user message + AI reply
        db.add(ChatMessage(sessionId=session.id, role="user", content=message))
        db.add(ChatMessage(sessionId=session.id, role="assistant", content=ai_reply))
        db.commit()

        return CoachChatData(session_id=session.id, coach_response=ai_reply)

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
                id=s.id, title=s.title,
                created_at=s.createdAt.isoformat(),
                updated_at=s.updatedAt.isoformat(),
            )
            for s in sessions
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
            id=session.id, title=session.title,
            created_at=session.createdAt.isoformat(),
        ),
        messages=[
            MessageOut(
                id=m.id, role=m.role, content=m.content,
                created_at=m.createdAt.isoformat(),
            )
            for m in messages
        ],
    )


def delete_session(db: Session, session_id: str, user_id: str) -> None:
    session = _get_session_or_raise(db, session_id, user_id)
    db.query(ChatMessage).filter(ChatMessage.sessionId == session_id).delete()
    db.delete(session)
    db.commit()
