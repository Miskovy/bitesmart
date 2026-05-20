import { Router } from "express";
import foodRoute from "./food/food.route";
import authRoute from "./auth/userAuth.route";
import predictionRoute from "./food/prediction.route";
import profileRoute from "./user/profile.route";
import coachRoute from "./coach/coach.route"
//! Created by Antigravity: Import daily logs route
import dailyLogsRoute from "./user/dailyLogs.route";
//! Created by Antigravity: Import symptom and mode settings routes
import symptomRoute from "./user/symptom.route";
import modeSettingsRoute from "./user/modeSettings.route";
//! Created by Antigravity: Import challenges and leaderboard routes
import challengeRoute from "./user/challenge.route";
import leaderboardRoute from "./user/leaderboard.route";
import { authenticated } from "../middlewares/Authenticated";

const router = Router();

router.use("/food", foodRoute);
router.use("/auth", authRoute);
router.use("/prediction", predictionRoute);
router.use(authenticated);
router.use("/profile", profileRoute);
router.use("/coach", coachRoute);
//! Created by Antigravity: Register daily logs route
router.use("/logs", dailyLogsRoute);
//! Created by Antigravity: Register symptom and mode settings routes
router.use("/symptoms", symptomRoute);
router.use("/settings", modeSettingsRoute);
//! Created by Antigravity: Register challenges and leaderboard routes
router.use("/challenges", challengeRoute);
router.use("/leaderboard", leaderboardRoute);

export default router;