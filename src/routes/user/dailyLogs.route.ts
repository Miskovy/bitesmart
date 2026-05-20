import { Router } from "express";
import catchAsync from "../../utils/catchAsync";
import {
    logMealController,
    deleteMealLogController,
    getMealLogsByDateController,
    getDailySummaryController,
    logWaterController,
    getWaterLogsByDateController,
    //! Created by Antigravity: Import day completion controllers
    completeDayController,
    getCompletionSummaryController
} from "../../controllers/user/dailyLogs.controller";

const router = Router();

//! Created by Antigravity: Routes for daily meal logging
router.post("/", catchAsync(logMealController));
router.delete("/:logId", catchAsync(deleteMealLogController));
router.get("/", catchAsync(getMealLogsByDateController));
router.get("/summary", catchAsync(getDailySummaryController));

//! Created by Antigravity: Routes for water/hydration logging
router.post("/water", catchAsync(logWaterController));
router.get("/water", catchAsync(getWaterLogsByDateController));

//! Created by Antigravity: Routes for day completion summary and confirmation
router.post("/complete", catchAsync(completeDayController));
router.get("/complete", catchAsync(getCompletionSummaryController));

export default router;
