import uuid
from typing import Any

from sqlalchemy.orm import Session

from app.models.food_model import DailyLogs, FoodItem
from app.models.user_model import MealType
from app.services.coach_tools.base import CoachTool
from app.services.coach_tools.registry import register_tool


@register_tool
class LogMealTool(CoachTool):
    name = "log_meal"
    description = (
        "Log a food item the user has eaten. Records it immediately without "
        "asking for confirmation. Use when the user says they ate something "
        "or explicitly asks to log/record a meal."
    )
    parameters = {
        "type": "object",
        "properties": {
            "food_name": {
                "type": "string",
                "description": "Name of the food (e.g. 'rice', 'chicken breast').",
            },
            "quantity_grams": {
                "type": "number",
                "description": "Amount consumed in grams.",
            },
            "meal_type": {
                "type": "string",
                "enum": ["Breakfast", "Lunch", "Dinner", "Snack"],
                "description": "Which meal this belongs to.",
            },
        },
        "required": ["food_name", "quantity_grams", "meal_type"],
    }

    async def execute(self, db: Session, user_id: str, **kwargs: Any) -> dict[str, Any]:
        food_name = kwargs.get("food_name", "")
        quantity = kwargs.get("quantity_grams", 0)
        meal_type_str = kwargs.get("meal_type", "")

        # Find food
        food = (
            db.query(FoodItem)
            .filter(FoodItem.class_name.ilike(f"%{food_name}%"))
            .first()
        )
        if not food:
            return {"error": f"Food '{food_name}' not found. Try a different name."}

        # Validate meal type
        try:
            meal_type = MealType(meal_type_str)
        except ValueError:
            return {"error": f"Invalid meal type '{meal_type_str}'. Use Breakfast, Lunch, Dinner, or Snack."}

        # Compute nutrition
        m = quantity / 100.0

        # Insert log (flushed, not committed — will commit with chat messages)
        db.add(DailyLogs(
            id=str(uuid.uuid4()),
            userId=user_id,
            foodItemId=food.id,
            mealType=meal_type,
            quantity=quantity,
            unit="g",
        ))
        db.flush()

        return {
            "success": True,
            "logged": {
                "food": food.class_name,
                "quantity_grams": quantity,
                "meal_type": meal_type_str,
                "calories": round(food.cals_per_100g * m),
                "protein_g": round(food.protein_per_100g * m, 1),
                "carbs_g": round(food.carbs_per_100g * m, 1),
                "fats_g": round(food.fats_per_100g * m, 1),
            },
        }
