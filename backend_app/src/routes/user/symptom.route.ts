import { Router } from "express";
import catchAsync from "../../utils/catchAsync";
import {
    logSymptomController,
    logDailyCheckInController,
    getSymptomsByDateController,
    getSymptomHistoryController
} from "../../controllers/user/symptom.controller";

const router = Router();

//! Created by Antigravity: Routes for GLP-1 symptom logging
router.post("/", catchAsync(logSymptomController));
router.post("/daily-checkin", catchAsync(logDailyCheckInController));
router.get("/", catchAsync(getSymptomsByDateController));
router.get("/history", catchAsync(getSymptomHistoryController));

export default router;
