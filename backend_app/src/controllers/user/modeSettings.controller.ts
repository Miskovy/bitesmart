import { Request, Response } from "express";
import { 
    saveGlp1Settings, 
    saveRamadanSettings, 
    getGlp1Settings, 
    getFastingSettings, 
    saveFastingSettings 
} from "../../services/user/modeSettings.service";
import { BadRequest, UnauthorizedError } from "../../errors";
import { SuccessResponse } from "../../utils/Response";

//! Created by Antigravity: Controller to get GLP-1 settings
export const getGlp1SettingsController = async (req: Request, res: Response) => {
    const userId = req.user?.id;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    const result = await getGlp1Settings(userId);
    SuccessResponse(res, result, 200);
};

//! Created by Antigravity: Controller to save GLP-1 settings (High-Protein Goal, Hydration Reminder)
export const saveGlp1SettingsController = async (req: Request, res: Response) => {
    const userId = req.user?.id;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    const { highProteinGoal, hydrationReminderHours } = req.body;

    const result = await saveGlp1Settings(userId, { highProteinGoal, hydrationReminderHours });

    SuccessResponse(res, result, 200);
};

//! Created by Antigravity: Controller to get Fasting settings (formerly Ramadan Mode)
export const getFastingSettingsController = async (req: Request, res: Response) => {
    const userId = req.user?.id;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    const result = await getFastingSettings(userId);
    SuccessResponse(res, result, 200);
};

//! Created by Antigravity: Controller to save Fasting settings (formerly Ramadan Mode)
export const saveFastingSettingsController = async (req: Request, res: Response) => {
    const userId = req.user?.id;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    const { suhoorTime, iftarTime, hydrationFocus, isFastingMode } = req.body;

    const result = await saveFastingSettings(userId, { 
        suhoorTime, 
        iftarTime, 
        hydrationFocus, 
        isFastingMode 
    });

    SuccessResponse(res, result, 200);
};

//! Created by Antigravity: Controller to save Ramadan settings (backward compatibility)
export const saveRamadanSettingsController = async (req: Request, res: Response) => {
    const userId = req.user?.id;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    const { suhoorTime, iftarTime, hydrationFocus } = req.body;

    if (!suhoorTime || !iftarTime) {
        throw new BadRequest("suhoorTime and iftarTime are required");
    }

    const result = await saveRamadanSettings(userId, { suhoorTime, iftarTime, hydrationFocus });

    SuccessResponse(res, result, 200);
};
