import { Router } from "express";
import foodRoute from "./food/food.route";
import authRoute from "./auth/userAuth.route";
import predictionRoute from "./food/prediction.route";
import profileRoute from "./user/profile.route";
import coachRoute from "./coach/coach.route"
import dailyLogsRoute from "./user/dailyLogs.route";
import symptomRoute from "./user/symptom.route";
import modeSettingsRoute from "./user/modeSettings.route";
import challengeRoute from "./user/challenge.route";
import leaderboardRoute from "./user/leaderboard.route";
import insightsRoute from "./user/insights.route";
import { authenticated } from "../middlewares/Authenticated";

const router = Router();

router.use("/food", foodRoute);
router.use("/auth", authRoute);
router.use("/prediction", predictionRoute);
router.use(authenticated);
router.use("/profile", profileRoute);
router.use("/coach", coachRoute);
router.use("/logs", dailyLogsRoute);
router.use("/symptoms", symptomRoute);
router.use("/settings", modeSettingsRoute);
router.use("/challenges", challengeRoute);
router.use("/leaderboard", leaderboardRoute);
router.use("/insights", insightsRoute);

export default router;