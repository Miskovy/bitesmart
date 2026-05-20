import { Request, Response } from "express";
import { 
    logMeal, 
    deleteMealLog, 
    getMealLogsByDate, 
    getDailySummary,
    logWater,
    getWaterLogsByDate,
    //! Created by Antigravity: Import day completion services
    completeDay,
    getCompletionSummary
} from "../../services/user/dailyLogs.service";
import { BadRequest, UnauthorizedError } from "../../errors";
import { SuccessResponse } from "../../utils/Response";

//! Created by Antigravity: Controller to log a meal
export const logMealController = async (req: Request, res: Response) => {
    const userId = req.user?.id;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    const { foodItemId, mealType, quantity, unit, imageUrl } = req.body;

    if (!foodItemId || !mealType || quantity === undefined) {
        throw new BadRequest("foodItemId, mealType, and quantity are required.");
    }

    const validMealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"];
    if (!validMealTypes.includes(mealType)) {
        throw new BadRequest("mealType must be one of: Breakfast, Lunch, Dinner, Snack");
    }

    if (quantity <= 0) {
        throw new BadRequest("quantity must be greater than 0");
    }

    const result = await logMeal(userId, foodItemId, mealType, quantity, unit, imageUrl);

    SuccessResponse(res, result, 201);
};

//! Created by Antigravity: Controller to delete a meal log
export const deleteMealLogController = async (req: Request, res: Response) => {
    const userId = req.user?.id;
    const { logId } = req.params;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    if (!logId) {
        throw new BadRequest("Log ID is required");
    }

    const result = await deleteMealLog(userId, logId as string);

    SuccessResponse(res, result, 200);
};

//! Created by Antigravity: Controller to get meal logs by date
export const getMealLogsByDateController = async (req: Request, res: Response) => {
    const userId = req.user?.id;
    const { date } = req.query;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    if (!date || typeof date !== "string") {
        throw new BadRequest("date query parameter is required (format: YYYY-MM-DD)");
    }

    const logs = await getMealLogsByDate(userId, date);

    SuccessResponse(res, logs, 200);
};

//! Created by Antigravity: Controller to get the full daily nutrition summary (consumed vs target)
export const getDailySummaryController = async (req: Request, res: Response) => {
    const userId = req.user?.id;
    const { date } = req.query;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    if (!date || typeof date !== "string") {
        throw new BadRequest("date query parameter is required (format: YYYY-MM-DD)");
    }

    const summary = await getDailySummary(userId, date);

    SuccessResponse(res, summary, 200);
};

//! Created by Antigravity: Controller to log water intake
export const logWaterController = async (req: Request, res: Response) => {
    const userId = req.user?.id;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    const { amount_ml, dateStr } = req.body;

    if (amount_ml === undefined) {
        throw new BadRequest("amount_ml is required");
    }

    const result = await logWater(userId, Number(amount_ml), dateStr);

    SuccessResponse(res, result, 201);
};

//! Created by Antigravity: Controller to get water logs by date
export const getWaterLogsByDateController = async (req: Request, res: Response) => {
    const userId = req.user?.id;
    const { date } = req.query;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    if (!date || typeof date !== "string") {
        throw new BadRequest("date query parameter is required (format: YYYY-MM-DD)");
    }

    const result = await getWaterLogsByDate(userId, date);

    SuccessResponse(res, result, 200);
};

//! Created by Antigravity: Controller to mark a day as completed and fetch summary
export const completeDayController = async (req: Request, res: Response) => {
    const userId = req.user?.id;
    const { dateStr } = req.body;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    if (!dateStr || typeof dateStr !== "string") {
        throw new BadRequest("dateStr is required in body (format: YYYY-MM-DD)");
    }

    const result = await completeDay(userId, dateStr);
    SuccessResponse(res, result, 200);
};

//! Created by Antigravity: Controller to get day completion summary (targets vs consumed with coach insights)
export const getCompletionSummaryController = async (req: Request, res: Response) => {
    const userId = req.user?.id;
    const { date } = req.query;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    if (!date || typeof date !== "string") {
        throw new BadRequest("date query parameter is required (format: YYYY-MM-DD)");
    }

    const result = await getCompletionSummary(userId, date);
    SuccessResponse(res, result, 200);
};
