"""
Coach Tools — extensible tool-calling system for the AI coach.

Usage in coach_service::

    from app.services.coach_tools import registry

    declarations = registry.get_all_declarations()  # for Gemini config
    tool = registry.get("search_food")               # dispatch by name
    result = await tool.execute(db, user_id, query="rice")
"""

from app.services.coach_tools.registry import registry  # noqa: F401

# Importing the tools sub-package triggers all @register_tool decorators
import app.services.coach_tools.tools  # noqa: F401
