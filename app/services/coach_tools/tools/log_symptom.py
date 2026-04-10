import uuid
from typing import Any

from sqlalchemy.orm import Session

from app.models.food_model import SymptomLog
from app.services.coach_tools.base import CoachTool
from app.services.coach_tools.registry import register_tool


@register_tool
class LogSymptomTool(CoachTool):
    name = "log_symptom"
    description = (
        "Log a health symptom for the user (e.g. nausea, fatigue, bloating). "
        "Especially important for GLP-1 users to track side effects. "
        "Use when the user reports feeling unwell or mentions a symptom."
    )
    parameters = {
        "type": "object",
        "properties": {
            "symptom": {
                "type": "string",
                "description": "Name of the symptom (e.g. 'nausea', 'fatigue', 'bloating').",
            },
            "severity": {
                "type": "integer",
                "description": "Severity from 1 (mild) to 10 (severe). Ask the user if not provided.",
            },
            "notes": {
                "type": "string",
                "description": "Optional additional notes about the symptom.",
            },
        },
        "required": ["symptom", "severity"],
    }

    async def execute(self, db: Session, user_id: str, **kwargs: Any) -> dict[str, Any]:
        symptom = kwargs.get("symptom", "")
        severity = kwargs.get("severity", 5)
        notes = kwargs.get("notes")

        if not symptom:
            return {"error": "Symptom name is required."}
        if not 1 <= severity <= 10:
            return {"error": "Severity must be between 1 and 10."}

        db.add(SymptomLog(
            id=str(uuid.uuid4()),
            userId=user_id,
            symptom=symptom,
            severity=severity,
            notes=notes,
        ))
        db.flush()

        return {
            "success": True,
            "logged": {
                "symptom": symptom,
                "severity": severity,
                "notes": notes,
            },
        }
