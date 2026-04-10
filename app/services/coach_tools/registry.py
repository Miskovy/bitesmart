"""
Central registry for coach tools.

Tools register themselves via the ``@register_tool`` decorator.
The coach service imports ``registry`` to get declarations and dispatch calls.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from app.services.coach_tools.base import CoachTool


class ToolRegistry:
    """Stores tool instances keyed by name."""

    def __init__(self) -> None:
        self._tools: dict[str, CoachTool] = {}

    # Mutation
    def register(self, tool: CoachTool) -> None:
        if tool.name in self._tools:
            raise ValueError(f"Duplicate tool name: '{tool.name}'")
        self._tools[tool.name] = tool

    # Lookups
    def get(self, name: str) -> CoachTool | None:
        return self._tools.get(name)

    def get_all_declarations(self) -> list[dict]:
        """Return Gemini function-declaration dicts for every registered tool."""
        return [t.to_declaration() for t in self._tools.values()]

    def get_tool_summary(self) -> str:
        """One-line-per-tool summary for inclusion in the system prompt."""
        return "\n".join(
            f"- {t.name}: {t.description}" for t in self._tools.values()
        )

    def __len__(self) -> int:
        return len(self._tools)


# Module-level singleton
registry = ToolRegistry()


def register_tool(cls: type[CoachTool]) -> type[CoachTool]:
    """Class decorator — instantiates and registers a CoachTool subclass."""
    registry.register(cls())
    return cls
