import uuid

from sqlalchemy import Boolean, Column, Date, DateTime, Enum, Float, ForeignKey, Integer, String, Text, func
from sqlalchemy.orm import relationship

from app.db.database import Base
from app.models.user_model import MealType


# ── Recipes ───────────────────────────────────────────────────────────────────

class Recipe(Base):
    __tablename__ = "recipes"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    authorId = Column(String(36), ForeignKey("users.id"), nullable=False)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    instructions = Column(Text, nullable=True)

    # Meta
    prepTimeMinutes = Column(Integer, nullable=True)
    cookTimeMinutes = Column(Integer, nullable=True)
    isPublic = Column(Boolean, default=False)

    # Derived Nutrition
    totalCalories = Column(Integer, nullable=True)
    totalProtein = Column(Float, nullable=True)

    # Relationships
    author = relationship("User", back_populates="recipes")
    ingredients = relationship("RecipeIngredient", back_populates="recipe", cascade="all, delete-orphan")
    meal_plan_items = relationship("MealPlanItem", back_populates="recipe")


class RecipeIngredient(Base):
    __tablename__ = "recipe_ingredients"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    recipeId = Column(String(36), ForeignKey("recipes.id"), nullable=False)
    foodItemId = Column(Integer, ForeignKey("food_items.id"), nullable=False)
    quantity = Column(Float, nullable=False)
    unit = Column(String(50), nullable=False)

    recipe = relationship("Recipe", back_populates="ingredients")
    food_item = relationship("FoodItem", back_populates="recipe_ingredients")


# ── Meal Plans ────────────────────────────────────────────────────────────────

class MealPlan(Base):
    __tablename__ = "meal_plans"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    userId = Column(String(36), ForeignKey("users.id"), nullable=False)
    name = Column(String(255), nullable=True)
    startDate = Column(Date, nullable=True)
    endDate = Column(Date, nullable=True)
    status = Column(String(50), nullable=True)  # Active, Completed, Archived
    generatedByAI = Column(Boolean, default=False)

    user = relationship("User", back_populates="meal_plans")
    items = relationship("MealPlanItem", back_populates="meal_plan", cascade="all, delete-orphan")


class MealPlanItem(Base):
    __tablename__ = "meal_plan_items"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    planId = Column(String(36), ForeignKey("meal_plans.id"), nullable=False)
    foodItemId = Column(Integer, ForeignKey("food_items.id"), nullable=True)
    recipeId = Column(String(36), ForeignKey("recipes.id"), nullable=True)
    scheduledDate = Column(Date, nullable=False)
    mealType = Column(Enum(MealType), nullable=False)
    isConsumed = Column(Boolean, default=False)

    meal_plan = relationship("MealPlan", back_populates="items")
    food_item = relationship("FoodItem", back_populates="meal_plan_items")
    recipe = relationship("Recipe", back_populates="meal_plan_items")


# ── Shopping List ─────────────────────────────────────────────────────────────

class ShoppingListItem(Base):
    __tablename__ = "shopping_list"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    userId = Column(String(36), ForeignKey("users.id"), nullable=False)
    foodItemId = Column(Integer, ForeignKey("food_items.id"), nullable=False)
    quantity = Column(Float, nullable=True)
    unit = Column(String(50), nullable=True)
    isPurchased = Column(Boolean, default=False)
    talabatLink = Column(String(500), nullable=True)

    user = relationship("User", back_populates="shopping_items")
    food_item = relationship("FoodItem", back_populates="shopping_items")
