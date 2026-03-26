import enum
from sqlalchemy import Column, String, Integer, Float, Boolean, ForeignKey, DateTime, Enum, Text
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import UUID # Or use String(36) for MySQL
import uuid
from app.db.database import Base # Assuming you have a Base declarative_base()

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
    __tablename__ = "Users"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String(255), nullable=False)
    email = Column(String(255), nullable=False, unique=True)

    # Physical Stats
    gender = Column(Enum(Genders))
    age = Column(Integer, nullable=False)
    userGoal = Column(Enum(Goals))

    # Relationships
    targets = relationship("UserTarget", back_populates="user", uselist=False)
    medical = relationship("UserMedicalConditions", back_populates="user", uselist=False)
    logs = relationship("DailyLogs", back_populates="user")


class UserMedicalConditions(Base):
    __tablename__ = "userMedicalConditions"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    userId = Column(String(36), ForeignKey("Users.id"))

    isDiabetesType2 = Column(Boolean, default=False)
    isHypertension = Column(Boolean, default=False)
    isPCOS = Column(Boolean, default=False)
    isAnemia = Column(Boolean, default=False)

    user = relationship("User", back_populates="medical")


class UserTarget(Base):
    __tablename__ = "userTarget"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    userId = Column(String(36), ForeignKey("Users.id"))

    calTotal = Column(Integer, nullable=False)
    proteins = Column(Integer, nullable=False)
    carbs = Column(Integer, nullable=False)
    fats = Column(Integer, nullable=False)

    user = relationship("User", back_populates="targets")
