import uuid

from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Text, func
from sqlalchemy.orm import relationship

from app.db.database import Base


class Plan(Base):
    __tablename__ = "plans"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String(100), nullable=False)
    monthlyPrice = Column(Integer, nullable=False)
    yearlyPrice = Column(Integer, nullable=False)
    features = Column(Text, nullable=True)  # JSON string of enabled features

    subscriptions = relationship("UserSubscription", back_populates="plan")


class UserSubscription(Base):
    __tablename__ = "user_subscriptions"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    userId = Column(String(36), ForeignKey("users.id"), nullable=False)
    planId = Column(String(36), ForeignKey("plans.id"), nullable=False)
    status = Column(String(50), nullable=True)  # Active, Cancelled, Expired
    startDate = Column(DateTime, nullable=True)
    endDate = Column(DateTime, nullable=True)

    user = relationship("User", back_populates="subscriptions")
    plan = relationship("Plan", back_populates="subscriptions")
