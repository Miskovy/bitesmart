from typing import Any

from sqlalchemy.orm import Session

from app.models.food_model import FoodItem
from app.services.coach_tools.base import CoachTool
from app.services.coach_tools.registry import register_tool


@register_tool
class SearchFoodTool(CoachTool):
    name = "search_food"
    description = (
        "Search the Bitesmart food database by name. "
        "Returns matching foods with their nutrition per 100 g. "
        "Use when the user asks about available foods or nutrition facts."
    )
    parameters = {
        "type": "object",
        "properties": {
            "query": {
                "type": "string",
                "description": "Food name or partial name to search for (e.g. 'rice', 'chicken').",
            },
        },
        "required": ["query"],
    }

    async def execute(self, db: Session, user_id: str, **kwargs: Any) -> dict[str, Any]:
        query = kwargs.get("query", "")
        results = (
            db.query(FoodItem)
            .filter(FoodItem.class_name.ilike(f"%{query}%"))
            .limit(10)
            .all()
        )

        if not results:
            return {"found": 0, "message": f"No foods matching '{query}' in the database."}

        return {
            "found": len(results),
            "foods": [
                {
                    "name": f.class_name,
                    "calories_per_100g": f.cals_per_100g,
                    "protein_per_100g": f.protein_per_100g,
                    "carbs_per_100g": f.carbs_per_100g,
                    "fats_per_100g": f.fats_per_100g,
                }
                for f in results
            ],
        }
