import { Router } from "express";
import catchAsync from "../../utils/catchAsync";
import { getDashboardController } from "../../controllers/user/dashboard.controller";

const router = Router();

router.get("/", catchAsync(getDashboardController));

export default router;
