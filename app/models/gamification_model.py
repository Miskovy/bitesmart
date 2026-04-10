import uuid

from sqlalchemy import Column, DateTime, Float, ForeignKey, Integer, String, Text, func
from sqlalchemy.orm import relationship

from app.db.database import Base


# ── Badges ────────────────────────────────────────────────────────────────────

class Badge(Base):
    __tablename__ = "badges"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String(100), nullable=False)
    description = Column(String(500), nullable=True)
    iconUrl = Column(String(500), nullable=True)
    requiredXp = Column(Integer, nullable=True)

    user_badges = relationship("UserBadge", back_populates="badge")


class UserBadge(Base):
    __tablename__ = "user_badges"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    userId = Column(String(36), ForeignKey("users.id"), nullable=False)
    badgeId = Column(String(36), ForeignKey("badges.id"), nullable=False)
    earnedAt = Column(DateTime, default=func.now())

    user = relationship("User", back_populates="badges")
    badge = relationship("Badge", back_populates="user_badges")


# ── Community Challenges ──────────────────────────────────────────────────────

class CommunityChallenge(Base):
    __tablename__ = "community_challenges"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    title = Column(String(255), nullable=True)
    description = Column(Text, nullable=True)
    startDate = Column(DateTime, nullable=True)
    endDate = Column(DateTime, nullable=True)
    participantsCount = Column(Integer, default=0)

    participants = relationship("UserChallenge", back_populates="challenge")


class UserChallenge(Base):
    __tablename__ = "user_challenges"

    userId = Column(String(36), ForeignKey("users.id"), primary_key=True)
    challengeId = Column(String(36), ForeignKey("community_challenges.id"), primary_key=True)
    progress = Column(Float, nullable=True)  # Percentage completed
    status = Column(String(50), nullable=True)  # Joined, Completed

    user = relationship("User", back_populates="challenges")
    challenge = relationship("CommunityChallenge", back_populates="participants")
