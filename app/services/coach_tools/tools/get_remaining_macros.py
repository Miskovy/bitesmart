from datetime import date
from typing import Any

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.food_model import DailyLogs, FoodItem
from app.models.user_model import UserTarget
from app.services.coach_tools.base import CoachTool
from app.services.coach_tools.registry import register_tool


@register_tool
class GetRemainingMacrosTool(CoachTool):
    name = "get_remaining_macros"
    description = (
        "Calculate how many calories, protein, carbs, and fats the user has "
        "left for today (targets minus consumed). Use when the user asks about "
        "their remaining budget or how much they can still eat."
    )
    parameters = None

    async def execute(self, db: Session, user_id: str, **kwargs: Any) -> dict[str, Any]:
        targets = db.query(UserTarget).filter(UserTarget.userId == user_id).first()
        if not targets:
            return {"error": "No nutrition targets set for this user."}

        logs = (
            db.query(DailyLogs, FoodItem)
            .join(FoodItem, DailyLogs.foodItemId == FoodItem.id)
            .filter(DailyLogs.userId == user_id)
            .filter(func.date(DailyLogs.loggedAt) == date.today())
            .all()
        )

        consumed = {"cals": 0.0, "protein": 0.0, "carbs": 0.0, "fats": 0.0}
        for log, food in logs:
            m = log.quantity / 100.0
            consumed["cals"] += food.cals_per_100g * m
            consumed["protein"] += food.protein_per_100g * m
            consumed["carbs"] += food.carbs_per_100g * m
            consumed["fats"] += food.fats_per_100g * m

        return {
            "targets": {
                "calories": targets.calTotal,
                "protein_g": targets.proteins,
                "carbs_g": targets.carbs,
                "fats_g": targets.fats,
            },
            "consumed": {
                "calories": round(consumed["cals"]),
                "protein_g": round(consumed["protein"]),
                "carbs_g": round(consumed["carbs"]),
                "fats_g": round(consumed["fats"]),
            },
            "remaining": {
                "calories": targets.calTotal - round(consumed["cals"]),
                "protein_g": targets.proteins - round(consumed["protein"]),
                "carbs_g": targets.carbs - round(consumed["carbs"]),
                "fats_g": targets.fats - round(consumed["fats"]),
            },
        }
