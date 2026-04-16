import enum
import uuid

from sqlalchemy import Boolean, Column, DateTime, Enum, Float, ForeignKey, Integer, String, Text, func
from sqlalchemy.orm import relationship

from app.db.database import Base
from app.models.user_model import MealType


# ── Enums ─────────────────────────────────────────────────────────────────────

class FoodSource(enum.Enum):
    USDA = "USDA"
    OpenFood = "OpenFood"
    Local = "Local"
    UserCreated = "UserCreated"


# ── Food Items ────────────────────────────────────────────────────────────────

class FoodItem(Base):
    __tablename__ = "food_items"

    id = Column(Integer, primary_key=True, index=True)
    class_name = Column(String(100), unique=True, index=True, nullable=False)

    # Volume calculation fields
    avg_height_cm = Column(Float, nullable=False, default=2.0)
    density_g_cm3 = Column(Float, nullable=False, default=1.0)

    # Nutritional fields (per 100g)
    protein_per_100g = Column(Float, nullable=False, default=0.0)
    carbs_per_100g = Column(Float, nullable=False, default=0.0)
    fats_per_100g = Column(Float, nullable=False, default=0.0)
    cals_per_100g = Column(Float, nullable=False, default=0.0)

    # Micronutrients
    iron_mg = Column(Float, nullable=True)
    sodium_mg = Column(Float, nullable=True)

    # Meta
    servingUnit = Column(String(50), nullable=True)
    barcode = Column(String(100), unique=True, nullable=True)
    source = Column(Enum(FoodSource), nullable=True)
    isVerified = Column(Boolean, default=False)

    # Relationships
    logs = relationship("DailyLogs", back_populates="food_item")
    recipe_ingredients = relationship("RecipeIngredient", back_populates="food_item")
    meal_plan_items = relationship("MealPlanItem", back_populates="food_item")
    shopping_items = relationship("ShoppingListItem", back_populates="food_item")


# ── Daily Logs ────────────────────────────────────────────────────────────────

class DailyLogs(Base):
    __tablename__ = "dailylogs"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    userId = Column(String(36), ForeignKey("users.id"))
    foodItemId = Column(Integer, ForeignKey("food_items.id"))
    mealType = Column(Enum(MealType), nullable=False)
    quantity = Column(Float, nullable=False)
    unit = Column(String(50), default="g")
    imageUrl = Column(String(500), nullable=True)
    loggedAt = Column(DateTime, nullable=False, default=func.now())

    user = relationship("User", back_populates="logs")
    food_item = relationship("FoodItem", back_populates="logs")
    training_data = relationship("AiTrainingData", back_populates="log", uselist=False)


# ── Water Logs ────────────────────────────────────────────────────────────────

class WaterLog(Base):
    __tablename__ = "water_logs"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    userId = Column(String(36), ForeignKey("users.id"), nullable=False)
    amount_ml = Column(Integer, nullable=False)
    loggedAt = Column(DateTime, nullable=False, default=func.now())

    user = relationship("User", back_populates="water_logs")


# ── Symptom Logs (GLP-1) ─────────────────────────────────────────────────────

class SymptomLog(Base):
    __tablename__ = "symptom_logs"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    userId = Column(String(36), ForeignKey("users.id"), nullable=False)
    symptom = Column(String(100), nullable=False)
    severity = Column(Integer, nullable=True)  # 1-10 scale
    notes = Column(Text, nullable=True)
    loggedAt = Column(DateTime, nullable=False, default=func.now())

    user = relationship("User", back_populates="symptom_logs")

# ── AI Training Data (RLHF) ──────────────────────────────────────────────────

class AiTrainingData(Base):
    __tablename__ = "ai_training_data"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    userId = Column(String(36), ForeignKey("users.id"), nullable=True)
    logId = Column(String(36), ForeignKey("dailylogs.id"), nullable=True)
    originalPrediction = Column(String(255), nullable=True)
    userCorrection = Column(String(255), nullable=True)
    imageSnapshot = Column(String(500), nullable=True)
    isReviewedByAdmin = Column(Boolean, default=False)
    createdAt = Column(DateTime, nullable=False, default=func.now())

    user = relationship("User")
    log = relationship("DailyLogs", back_populates="training_data")

