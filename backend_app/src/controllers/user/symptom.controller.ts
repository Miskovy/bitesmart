import { Request, Response } from "express";
import { logSymptom, logDailyCheckIn, getSymptomsByDate, getSymptomHistory } from "../../services/user/symptom.service";
import { BadRequest, UnauthorizedError } from "../../errors";
import { SuccessResponse } from "../../utils/Response";

//! Created by Antigravity: Controller to log a single symptom
export const logSymptomController = async (req: Request, res: Response) => {
    const userId = req.user?.id;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    const { symptom, severity, notes } = req.body;

    if (!symptom || severity === undefined) {
        throw new BadRequest("symptom and severity are required");
    }

    const result = await logSymptom(userId, symptom, severity, notes);

    SuccessResponse(res, result, 201);
};

//! Created by Antigravity: Controller to log the full GLP-1 daily check-in (Nausea + Appetite)
export const logDailyCheckInController = async (req: Request, res: Response) => {
    const userId = req.user?.id;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    const { nauseaLevel, appetiteLevel, notes } = req.body;

    if (nauseaLevel === undefined || appetiteLevel === undefined) {
        throw new BadRequest("nauseaLevel and appetiteLevel are required");
    }

    const result = await logDailyCheckIn(userId, nauseaLevel, appetiteLevel, notes);

    SuccessResponse(res, result, 201);
};

//! Created by Antigravity: Controller to get symptoms by date
export const getSymptomsByDateController = async (req: Request, res: Response) => {
    const userId = req.user?.id;
    const { date } = req.query;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    if (!date || typeof date !== "string") {
        throw new BadRequest("date query parameter is required (format: YYYY-MM-DD)");
    }

    const logs = await getSymptomsByDate(userId, date);

    SuccessResponse(res, logs, 200);
};

//! Created by Antigravity: Controller to get symptom history with pagination
export const getSymptomHistoryController = async (req: Request, res: Response) => {
    const userId = req.user?.id;
    const { page, limit } = req.query;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    const logs = await getSymptomHistory(
        userId,
        page ? Number(page) : 1,
        limit ? Number(limit) : 20
    );

    SuccessResponse(res, logs, 200);
};
