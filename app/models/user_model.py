import enum
import uuid

from sqlalchemy import Boolean, Column, DateTime, Enum, Float, Integer, String, ForeignKey, func
from sqlalchemy.orm import relationship

from app.db.database import Base


# ── Enums ─────────────────────────────────────────────────────────────────────

class Genders(enum.Enum):
    Male = "Male"
    Female = "Female"


class Goals(enum.Enum):
    WeightLoss = "WeightLoss"
    Maintenance = "Maintenance"
    MuscleGain = "MuscleGain"


class ActivityLevel(enum.Enum):
    Sedentary = "Sedentary"
    LightlyActive = "LightlyActive"
    ModeratelyActive = "ModeratelyActive"
    VeryActive = "VeryActive"


class MealType(enum.Enum):
    Breakfast = "Breakfast"
    Lunch = "Lunch"
    Dinner = "Dinner"
    Snack = "Snack"


class UserRole(enum.Enum):
    User = "User"
    Admin = "Admin"
    ContentManager = "ContentManager"


# ── Users ─────────────────────────────────────────────────────────────────────

class User(Base):
    __tablename__ = "users"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String(255), nullable=False)
    password = Column(String(255), nullable=False)
    email = Column(String(255), nullable=False, unique=True)
    googleId = Column(String(255), nullable=True)
    avatar = Column(String(500), nullable=True)
    role = Column(Enum(UserRole), nullable=False, default=UserRole.User)

    # Physical Stats
    height = Column(Float, nullable=True)
    weight = Column(Float, nullable=True)
    BMI = Column(Float, nullable=True)
    gender = Column(Enum(Genders))
    age = Column(Integer, nullable=False)
    activityLevel = Column(Enum(ActivityLevel), nullable=True)

    # Gamification
    xp = Column(Integer, nullable=False, default=0)
    userGoal = Column(Enum(Goals))
    created_at = Column(DateTime, default=func.now())

    # Relationships
    targets = relationship("UserTarget", back_populates="user", uselist=False)
    medical = relationship("UserMedicalConditions", back_populates="user", uselist=False)
    dietary_preferences = relationship("UserDietaryPreferences", back_populates="user", uselist=False)
    logins = relationship("UserLogin", back_populates="user")
    logs = relationship("DailyLogs", back_populates="user")
    water_logs = relationship("WaterLog", back_populates="user")
    symptom_logs = relationship("SymptomLog", back_populates="user")
    subscriptions = relationship("UserSubscription", back_populates="user")
    meal_plans = relationship("MealPlan", back_populates="user")
    shopping_items = relationship("ShoppingListItem", back_populates="user")
    recipes = relationship("Recipe", back_populates="author")
    badges = relationship("UserBadge", back_populates="user")
    challenges = relationship("UserChallenge", back_populates="user")


# ── User Logins (streak tracking) ────────────────────────────────────────────

class UserLogin(Base):
    __tablename__ = "user_logins"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    userId = Column(String(36), ForeignKey("users.id"), nullable=False)
    lastLogin = Column(DateTime, nullable=False)
    streak = Column(Integer, nullable=False, default=0)

    user = relationship("User", back_populates="logins")


# ── Health Profile ────────────────────────────────────────────────────────────

class UserMedicalConditions(Base):
    __tablename__ = "usermedicalconditions"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    userId = Column(String(36), ForeignKey("users.id"))

    # General
    isDiabetesType1 = Column(Boolean, default=False)
    isDiabetesType2 = Column(Boolean, default=False)
    isHypertension = Column(Boolean, default=False)
    isPCOS = Column(Boolean, default=False)
    isAnemia = Column(Boolean, default=False)

    # Digestive
    isCeliacDisease = Column(Boolean, default=False)
    isIBS = Column(Boolean, default=False)

    user = relationship("User", back_populates="medical")


class UserDietaryPreferences(Base):
    __tablename__ = "user_dietary_preferences"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    userId = Column(String(36), ForeignKey("users.id"))

    isVegetarian = Column(Boolean, default=False)
    isVegan = Column(Boolean, default=False)
    isKeto = Column(Boolean, default=False)
    isPaleo = Column(Boolean, default=False)
    isGlutenFree = Column(Boolean, default=False)
    isHalal = Column(Boolean, default=False)
    isPescatarian = Column(Boolean, default=False)

    # GLP-1 Mode
    isGlp1User = Column(Boolean, default=False)

    user = relationship("User", back_populates="dietary_preferences")


# ── Nutrition Targets ─────────────────────────────────────────────────────────

class UserTarget(Base):
    __tablename__ = "usertarget"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    userId = Column(String(36), ForeignKey("users.id"))

    # Macros
    calTotal = Column(Integer, nullable=False)
    proteins = Column(Integer, nullable=False)
    carbs = Column(Integer, nullable=False)
    fats = Column(Integer, nullable=False)

    # Micros
    iron_mg = Column(Float, nullable=True)
    sodium_mg = Column(Float, nullable=True)
    vitamin_d_iu = Column(Float, nullable=True)
    water_ml = Column(Integer, default=2000)

    user = relationship("User", back_populates="targets")
