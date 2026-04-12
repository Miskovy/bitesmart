from datetime import date
from typing import Any

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.food_model import DailyLogs, FoodItem
from app.models.meal_plan_model import Recipe, RecipeIngredient
from app.models.user_model import UserDietaryPreferences, UserMedicalConditions, UserTarget
from app.services.coach_tools.base import CoachTool
from app.services.coach_tools.registry import register_tool


@register_tool
class RecommendRecipeTool(CoachTool):
    name = "recommend_recipe"
    description = (
        "Gather the user's full nutritional context so you can recommend personalized "
        "recipes. Returns remaining macros, dietary preferences, medical conditions, "
        "and meal-specific guidelines. Also searches the Bitesmart recipe database. "
        "Use when the user asks 'what should I eat?', 'give me a recipe', 'meal ideas', "
        "or 'what's good for lunch?'."
    )
    parameters = {
        "type": "object",
        "properties": {
            "meal_type": {
                "type": "string",
                "enum": [
                    "Breakfast", "Lunch", "Dinner", "Snack",
                    "PreWorkout", "PostWorkout",
                ],
                "description": (
                    "The type of meal the user wants. Infer from context — "
                    "if they mention the gym, use PreWorkout or PostWorkout."
                ),
            },
        },
        "required": ["meal_type"],
    }

    async def execute(self, db: Session, user_id: str, **kwargs: Any) -> dict[str, Any]:
        meal_type = kwargs.get("meal_type", "Lunch")

        # ── Remaining macros ──────────────────────────────────────────
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

        remaining = {
            "calories": targets.calTotal - round(consumed["cals"]),
            "protein_g": targets.proteins - round(consumed["protein"]),
            "carbs_g": targets.carbs - round(consumed["carbs"]),
            "fats_g": targets.fats - round(consumed["fats"]),
        }

        # ── Dietary preferences ───────────────────────────────────────
        prefs = db.query(UserDietaryPreferences).filter(
            UserDietaryPreferences.userId == user_id
        ).first()

        diets = []
        if prefs:
            pref_map = {
                "isVegetarian": "Vegetarian",
                "isVegan": "Vegan",
                "isKeto": "Keto",
                "isPaleo": "Paleo",
                "isGlutenFree": "Gluten-Free",
                "isHalal": "Halal",
                "isPescatarian": "Pescatarian",
            }
            diets = [label for attr, label in pref_map.items() if getattr(prefs, attr, False)]

        is_glp1 = prefs.isGlp1User if prefs else False

        # ── Medical conditions ────────────────────────────────────────
        medical = db.query(UserMedicalConditions).filter(
            UserMedicalConditions.userId == user_id
        ).first()

        conditions = []
        if medical:
            cond_map = {
                "isDiabetesType1": "Type 1 Diabetes (watch sugar/carbs)",
                "isDiabetesType2": "Type 2 Diabetes (low glycemic index)",
                "isHypertension": "Hypertension (low sodium)",
                "isAnemia": "Anemia (iron-rich foods needed)",
                "isPCOS": "PCOS (anti-inflammatory, balanced carbs)",
                "isCeliacDisease": "Celiac (strictly no gluten)",
                "isIBS": "IBS (avoid FODMAPs and trigger foods)",
            }
            conditions = [label for attr, label in cond_map.items() if getattr(medical, attr, False)]

        # ── Search DB recipes ─────────────────────────────────────────
        db_recipes = (
            db.query(Recipe)
            .filter(Recipe.isPublic == True)  # noqa: E712
            .filter(
                (Recipe.totalCalories <= remaining["calories"])
                | (Recipe.totalCalories == None)  # noqa: E711
            )
            .limit(5)
            .all()
        )

        saved_recipes = []
        for r in db_recipes:
            ingredients = db.query(RecipeIngredient, FoodItem).join(
                FoodItem, RecipeIngredient.foodItemId == FoodItem.id
            ).filter(RecipeIngredient.recipeId == r.id).all()

            saved_recipes.append({
                "name": r.name,
                "description": r.description,
                "prep_time_min": r.prepTimeMinutes,
                "cook_time_min": r.cookTimeMinutes,
                "total_calories": r.totalCalories,
                "total_protein_g": r.totalProtein,
                "ingredients": [
                    {"food": fi.class_name, "qty": ri.quantity, "unit": ri.unit}
                    for ri, fi in ingredients
                ],
            })

        # ── Meal-type guidelines ──────────────────────────────────────
        meal_guidelines = {
            "Breakfast": "Light, energising. Include complex carbs and protein. E.g. eggs, oats, fruit, yoghurt.",
            "Lunch": "Balanced main meal. Good mix of protein, carbs, and veggies.",
            "Dinner": "Lighter than lunch. Focus on protein and vegetables, moderate carbs.",
            "Snack": "Small, 100-250 cal range. High protein or fiber to stay full.",
            "PreWorkout": "Easily digestible carbs + moderate protein, 30-60 min before gym. Avoid high fat.",
            "PostWorkout": "High protein + fast carbs within 30 min of training. Recover and rebuild.",
        }

        result: dict[str, Any] = {
            "meal_type": meal_type,
            "remaining_macros": remaining,
            "dietary_preferences": diets if diets else ["No specific diet"],
            "medical_conditions": conditions if conditions else ["None"],
            "is_glp1_user": is_glp1,
            "meal_guidelines": meal_guidelines.get(meal_type, ""),
            "instructions": (
                "Suggest 2-3 specific recipes with ingredient lists and approximate macros per serving. "
                "Each recipe MUST fit within the remaining macro budget. "
                "STRICTLY respect all dietary preferences and medical conditions listed above. "
                "Keep recipes practical and with commonly available ingredients."
            ),
        }

        if saved_recipes:
            result["bitesmart_recipes"] = saved_recipes
            result["instructions"] += (
                " Also consider the Bitesmart recipes included below — "
                "recommend them first if they fit the user's needs."
            )

        return result

