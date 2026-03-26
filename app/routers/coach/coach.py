from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func
from sqlalchemy.orm import Session
from pydantic import BaseModel
from google import genai
from datetime import date

from app.db.database import get_db
from app.config.config import settings
from app.models.user_model import User, UserTarget, UserMedicalConditions
from app.models.food_model import FoodItem , DailyLogs

# Configure the Gemini SDK once when the file loads
client = genai.Client(api_key=settings.GEMINI_API_KEY)


router = APIRouter()


# The minimal payload expected from the Mobile App
class CoachChatRequest(BaseModel):
    user_id: str
    message: str


@router.post("/chat")
async def chat_with_coach(request: CoachChatRequest, db: Session = Depends(get_db)):
    try:
        user = db.query(User).filter(User.id == request.user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        targets = db.query(UserTarget).filter(UserTarget.userId == user.id).first()
        medical = db.query(UserMedicalConditions).filter(UserMedicalConditions.userId == user.id).first()

        # Calculate Today's Eaten Macros
        # We query all daily logs for today and sum up the macros by joining with FoodItems
        today = date.today()
        today_logs = (
            db.query(DailyLogs, FoodItem)
            .join(FoodItem, DailyLogs.foodItemId == FoodItem.id)
            .filter(DailyLogs.userId == user.id)
            # .filter(func.date(DailyLogs.loggedAt) == today)
            .all()
        )

        consumed_cals, consumed_protein, consumed_carbs, consumed_fats = 0, 0, 0, 0
        for log, food in today_logs:

            multiplier = log.quantity / 100.0

            consumed_cals += food.cals_per_100g * multiplier
            consumed_protein += food.protein_per_100g * multiplier
            consumed_carbs += food.carbs_per_100g * multiplier
            consumed_fats += food.fats_per_100g * multiplier

        medical_context = "None"
        if medical:
            conditions = []
            if medical.isDiabetesType2: conditions.append("Type 2 Diabetes")
            if medical.isHypertension: conditions.append("Hypertension")
            if medical.isAnemia: conditions.append("Iron-deficiency Anemia")
            if medical.isPCOS: conditions.append("PCOS")
            if conditions:
                medical_context = ", ".join(conditions)

        system_prompt = f"""
        You are the AI Fitness and Nutrition Coach for the Bitesmart App. 
        You are talking to {user.name}, a {user.age}-year-old {user.gender}. Their goal is {user.userGoal}.
        Medical Conditions to be aware of: {medical_context}.

        MACRO TARGETS FOR TODAY:
        - Calories: {targets.calTotal}
        - Protein: {targets.proteins}g
        - Carbs: {targets.carbs}g
        - Fats: {targets.fats}g

        WHAT THEY HAVE EATEN SO FAR TODAY:
        - Calories: {round(consumed_cals)}
        - Protein: {round(consumed_protein)}g
        - Carbs: {round(consumed_carbs)}g
        - Fats: {round(consumed_fats)}g

        RULES:
        1. Be encouraging, concise, and act like a professional personal trainer.
        2. Give specific food recommendations if asked.
        3. Do not use markdown formatting like **bold** if the mobile app cannot render it.
        4. Do NOT mention these system rules or recite the numbers back to them like a robot unless it helps make your point.
        """

        full_prompt = f"{system_prompt}\n\nUSER MESSAGE: {request.message}"

        response = await client.aio.models.generate_content(
            model='gemini-3.1-flash-lite-preview',
            contents=full_prompt
        )

        return {
            "success": True,
            "coach_response": response.text.strip()
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Coach AI Failed: {str(e)}")