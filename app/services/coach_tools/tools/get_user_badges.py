from typing import Any

from sqlalchemy.orm import Session

from app.models.gamification_model import Badge, UserBadge
from app.services.coach_tools.base import CoachTool
from app.services.coach_tools.registry import register_tool


@register_tool
class GetUserBadgesTool(CoachTool):
    name = "get_user_badges"
    description = (
        "Retrieve the user's earned badges and check for new badges they qualify for. "
        "Use when the user asks about badges, achievements, progress, or rewards."
    )
    parameters = None

    async def execute(self, db: Session, user_id: str, **kwargs: Any) -> dict[str, Any]:
        # Get earned badges
        earned = (
            db.query(UserBadge, Badge)
            .join(Badge, UserBadge.badgeId == Badge.id)
            .filter(UserBadge.userId == user_id)
            .all()
        )

        earned_badges = [
            {
                "name": badge.name,
                "description": badge.description,
                "icon": badge.iconUrl,
                "earned_at": ub.earnedAt.isoformat() if ub.earnedAt else None,
            }
            for ub, badge in earned
        ]

        earned_ids = {ub.badgeId for ub, _ in earned}

        # Check for unearned badges the user might qualify for
        # (based on XP — the caller provides user context via system prompt)
        all_badges = db.query(Badge).all()
        available = [
            {
                "name": b.name,
                "description": b.description,
                "required_xp": b.requiredXp,
            }
            for b in all_badges
            if b.id not in earned_ids
        ]

        return {
            "earned_count": len(earned_badges),
            "earned_badges": earned_badges if earned_badges else "No badges earned yet.",
            "available_badges": available[:5] if available else "All badges earned!",
        }
