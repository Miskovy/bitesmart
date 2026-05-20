import { Router } from "express";
import catchAsync from "../../utils/catchAsync";
import { getLeaderboardController } from "../../controllers/user/leaderboard.controller";

const router = Router();

//! Created by Antigravity: Routes for leaderboard
router.get("/", catchAsync(getLeaderboardController));

export default router;
