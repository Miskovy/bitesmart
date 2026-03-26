from sqlalchemy import Column, Integer, String, Float, ForeignKey, Enum, DateTime, func
import uuid
from app.db.database import Base
from sqlalchemy.orm import relationship
from app.models.user_model import MealType


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

    logs = relationship("DailyLogs", back_populates="food_item")


class DailyLogs(Base):
    __tablename__ = "DailyLogs"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    userId = Column(String(36), ForeignKey("Users.id"))

    foodItemId = Column(Integer, ForeignKey("food_items.id"))

    mealType = Column(Enum(MealType), nullable=False)
    quantity = Column(Float, nullable=False)  # e.g., 65.5 (grams)
    unit = Column(String(50), default="g")

    # Relationships
    user = relationship("User", back_populates="logs")
    food_item = relationship("FoodItem", back_populates="logs")

    loggedAt = Column(DateTime, nullable=False, default=func.now())