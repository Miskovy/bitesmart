import { Router } from "express";
import catchAsync from "../../utils/catchAsync";
import { getDashboardController } from "../../controllers/user/dashboard.controller";
import { isAdmin } from "../../middlewares/isAdmin";

const router = Router();

router.get("/", isAdmin, catchAsync(getDashboardController));

export default router;
