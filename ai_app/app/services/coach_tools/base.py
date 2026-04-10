"""
Base class for all AI coach tools.

To add a new tool:
  1. Create a file in  app/services/coach_tools/tools/
  2. Subclass CoachTool, set  name / description / parameters
  3. Implement  execute()
  4. Decorate with  @register_tool
  5. Import it in  tools/__init__.py

That's it — the tool will be auto-registered and available to the AI.
"""

from abc import ABC, abstractmethod
from typing import Any

from sqlalchemy.orm import Session


class CoachTool(ABC):
    """Interface every coach tool must implement."""

    name: str
    """Unique snake_case identifier (e.g. 'search_food')."""

    description: str
    """What this tool does — Gemini reads this to decide when to call it."""

    parameters: dict | None
    """OpenAPI-subset JSON Schema for function params, or None if none."""

    @abstractmethod
    async def execute(self, db: Session, user_id: str, **kwargs: Any) -> dict[str, Any]:
        """
        Run the tool and return a result dict.

        The dict is sent to Gemini as a function_response so it can
        craft a human-friendly reply.  Return ``{"error": "..."}`` on
        failure so Gemini can tell the user what went wrong.
        """
        ...

    def to_declaration(self) -> dict[str, Any]:
        """Convert to a Gemini function-declaration dict."""
        decl: dict[str, Any] = {
            "name": self.name,
            "description": self.description,
        }
        if self.parameters:
            decl["parameters"] = self.parameters
        return decl
