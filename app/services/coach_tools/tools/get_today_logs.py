from datetime import date
from typing import Any

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.food_model import DailyLogs, FoodItem
from app.services.coach_tools.base import CoachTool
from app.services.coach_tools.registry import register_tool


@register_tool
class GetTodayLogsTool(CoachTool):
    name = "get_today_logs"
    description = (
        "Retrieve everything the user has eaten today with full nutritional "
        "breakdown. Use when the user asks 'what did I eat today' or similar."
    )
    parameters = None

    async def execute(self, db: Session, user_id: str, **kwargs: Any) -> dict[str, Any]:
        logs = (
            db.query(DailyLogs, FoodItem)
            .join(FoodItem, DailyLogs.foodItemId == FoodItem.id)
            .filter(DailyLogs.userId == user_id)
            .filter(func.date(DailyLogs.loggedAt) == date.today())
            .all()
        )

        if not logs:
            return {"meals": [], "message": "No meals logged today yet."}

        meals = []
        totals = {"calories": 0, "protein_g": 0.0, "carbs_g": 0.0, "fats_g": 0.0}

        for log, food in logs:
            m = log.quantity / 100.0
            entry = {
                "food": food.class_name,
                "quantity_grams": log.quantity,
                "meal_type": log.mealType.value,
                "calories": round(food.cals_per_100g * m),
                "protein_g": round(food.protein_per_100g * m, 1),
                "carbs_g": round(food.carbs_per_100g * m, 1),
                "fats_g": round(food.fats_per_100g * m, 1),
            }
            meals.append(entry)
            totals["calories"] += entry["calories"]
            totals["protein_g"] += entry["protein_g"]
            totals["carbs_g"] += entry["carbs_g"]
            totals["fats_g"] += entry["fats_g"]

        return {"meals": meals, "totals": {k: round(v, 1) for k, v in totals.items()}}
