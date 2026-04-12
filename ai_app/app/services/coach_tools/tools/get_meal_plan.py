from typing import Any

from sqlalchemy.orm import Session

from app.models.food_model import FoodItem
from app.models.meal_plan_model import MealPlan, MealPlanItem, Recipe
from app.services.coach_tools.base import CoachTool
from app.services.coach_tools.registry import register_tool


@register_tool
class GetMealPlanTool(CoachTool):
    name = "get_meal_plan"
    description = (
        "Retrieve the user's active meal plan with all scheduled items. "
        "Use when the user asks 'show my meal plan', 'what's my plan?', "
        "or 'what meals are planned?'."
    )
    parameters = None

    async def execute(self, db: Session, user_id: str, **kwargs: Any) -> dict[str, Any]:
        plan = (
            db.query(MealPlan)
            .filter(MealPlan.userId == user_id, MealPlan.status == "Active")
            .first()
        )

        if not plan:
            return {"message": "No active meal plan. Would you like me to create one?"}

        items = (
            db.query(MealPlanItem)
            .filter(MealPlanItem.planId == plan.id)
            .order_by(MealPlanItem.scheduledDate, MealPlanItem.mealType)
            .all()
        )

        plan_items = []
        for item in items:
            entry: dict[str, Any] = {
                "date": str(item.scheduledDate),
                "meal_type": item.mealType.value,
                "is_consumed": item.isConsumed,
            }
            if item.foodItemId:
                food = db.query(FoodItem).filter(FoodItem.id == item.foodItemId).first()
                if food:
                    entry["food"] = food.class_name
            if item.recipeId:
                recipe = db.query(Recipe).filter(Recipe.id == item.recipeId).first()
                if recipe:
                    entry["recipe"] = recipe.name
            plan_items.append(entry)

        return {
            "plan_id": plan.id,
            "name": plan.name,
            "start_date": str(plan.startDate),
            "end_date": str(plan.endDate),
            "generated_by_ai": plan.generatedByAI,
            "items": plan_items if plan_items else "No items scheduled yet.",
        }
