import { Router } from "express";
import catchAsync from "../../utils/catchAsync";
import {
    logMealController,
    deleteMealLogController,
    getMealLogsByDateController,
    getDailySummaryController
} from "../../controllers/user/dailyLogs.controller";

const router = Router();

//! Created by Antigravity: Routes for daily meal logging
router.post("/", catchAsync(logMealController));
router.delete("/:logId", catchAsync(deleteMealLogController));
router.get("/", catchAsync(getMealLogsByDateController));
router.get("/summary", catchAsync(getDailySummaryController));

export default router;
