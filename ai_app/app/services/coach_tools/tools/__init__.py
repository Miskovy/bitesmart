# Import every tool module here to trigger @register_tool decorators.
# To add a new tool: create the file, then add a single import below.

from app.services.coach_tools.tools.search_food import SearchFoodTool  # noqa: F401
from app.services.coach_tools.tools.log_meal import LogMealTool  # noqa: F401
from app.services.coach_tools.tools.get_today_logs import GetTodayLogsTool  # noqa: F401
from app.services.coach_tools.tools.get_remaining_macros import GetRemainingMacrosTool  # noqa: F401
from app.services.coach_tools.tools.log_water import LogWaterTool  # noqa: F401
from app.services.coach_tools.tools.log_symptom import LogSymptomTool  # noqa: F401
