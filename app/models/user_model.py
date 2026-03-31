import enum
import uuid

from sqlalchemy import Boolean, Column, Enum, Integer, String, ForeignKey
from sqlalchemy.orm import relationship

from app.db.database import Base


class Genders(enum.Enum):
    Male = "Male"
    Female = "Female"


class Goals(enum.Enum):
    WeightLoss = "WeightLoss"
    Maintenance = "Maintenance"
    MuscleGain = "MuscleGain"


class MealType(enum.Enum):
    Breakfast = "Breakfast"
    Lunch = "Lunch"
    Dinner = "Dinner"
    Snack = "Snack"


class User(Base):
    __tablename__ = "users"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String(255), nullable=False)
    email = Column(String(255), nullable=False, unique=True)
    gender = Column(Enum(Genders))
    age = Column(Integer, nullable=False)
    userGoal = Column(Enum(Goals))

    targets = relationship("UserTarget", back_populates="user", uselist=False)
    medical = relationship("UserMedicalConditions", back_populates="user", uselist=False)
    logs = relationship("DailyLogs", back_populates="user")


class UserMedicalConditions(Base):
    __tablename__ = "usermedicalconditions"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    userId = Column(String(36), ForeignKey("users.id"))
    isDiabetesType2 = Column(Boolean, default=False)
    isHypertension = Column(Boolean, default=False)
    isPCOS = Column(Boolean, default=False)
    isAnemia = Column(Boolean, default=False)

    user = relationship("User", back_populates="medical")


class UserTarget(Base):
    __tablename__ = "usertarget"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    userId = Column(String(36), ForeignKey("users.id"))
    calTotal = Column(Integer, nullable=False)
    proteins = Column(Integer, nullable=False)
    carbs = Column(Integer, nullable=False)
    fats = Column(Integer, nullable=False)

    user = relationship("User", back_populates="targets")
