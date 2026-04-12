import uuid
from datetime import date, timedelta
from typing import Any

from sqlalchemy.orm import Session

from app.models.meal_plan_model import MealPlan
from app.services.coach_tools.base import CoachTool
from app.services.coach_tools.registry import register_tool


@register_tool
class CreateMealPlanTool(CoachTool):
    name = "create_meal_plan"
    description = (
        "Create a new meal plan for the user. Use when the user asks you to "
        "'make me a meal plan', 'plan my week', or 'create a diet plan'. "
        "After creating the plan, describe the daily meals in your response."
    )
    parameters = {
        "type": "object",
        "properties": {
            "name": {
                "type": "string",
                "description": "A descriptive name for the plan (e.g. 'High Protein Week').",
            },
            "days": {
                "type": "integer",
                "description": "How many days the plan covers (e.g. 7 for a week).",
            },
        },
        "required": ["name", "days"],
    }

    async def execute(self, db: Session, user_id: str, **kwargs: Any) -> dict[str, Any]:
        name = kwargs.get("name", "My Meal Plan")
        days = kwargs.get("days", 7)

        # Archive any currently active plan
        active = (
            db.query(MealPlan)
            .filter(MealPlan.userId == user_id, MealPlan.status == "Active")
            .all()
        )
        for p in active:
            p.status = "Archived"

        plan = MealPlan(
            id=str(uuid.uuid4()),
            userId=user_id,
            name=name,
            startDate=date.today(),
            endDate=date.today() + timedelta(days=days),
            status="Active",
            generatedByAI=True,
        )
        db.add(plan)
        db.flush()

        return {
            "success": True,
            "plan_id": plan.id,
            "name": name,
            "start_date": str(plan.startDate),
            "end_date": str(plan.endDate),
            "days": days,
            "message": (
                "Meal plan created. Now describe the specific daily meals "
                "(breakfast, lunch, dinner, snacks) for each day in your response."
            ),
        }
