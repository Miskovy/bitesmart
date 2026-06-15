import { Router } from "express";
import catchAsync from "../../utils/catchAsync";
import { getInsightsController } from "../../controllers/user/insights.controller";

const router = Router();

router.get("/", catchAsync(getInsightsController));

export default router;
