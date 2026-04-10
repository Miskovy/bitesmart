import uuid
from typing import Any

from sqlalchemy.orm import Session

from app.models.food_model import WaterLog
from app.services.coach_tools.base import CoachTool
from app.services.coach_tools.registry import register_tool


@register_tool
class LogWaterTool(CoachTool):
    name = "log_water"
    description = (
        "Log water intake for the user in milliliters. "
        "Use when the user says they drank water or wants to track hydration."
    )
    parameters = {
        "type": "object",
        "properties": {
            "amount_ml": {
                "type": "integer",
                "description": "Amount of water in milliliters (e.g. 250 for a glass, 500 for a bottle).",
            },
        },
        "required": ["amount_ml"],
    }

    async def execute(self, db: Session, user_id: str, **kwargs: Any) -> dict[str, Any]:
        amount = kwargs.get("amount_ml", 0)
        if amount <= 0:
            return {"error": "Amount must be greater than 0."}

        db.add(WaterLog(
            id=str(uuid.uuid4()),
            userId=user_id,
            amount_ml=amount,
        ))
        db.flush()

        return {
            "success": True,
            "logged_ml": amount,
        }
