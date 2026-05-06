import { Router } from "express";
import foodRoute from "./food/food.route";
import authRoute from "./auth/userAuth.route";
import predictionRoute from "./food/prediction.route";
import profileRoute from "./user/profile.route";
import coachRoute from "./coach/coach.route"
import { authenticated } from "../middlewares/Authenticated";

const router = Router();

router.use("/food", foodRoute);
router.use("/login", authRoute);
router.use("/prediction", predictionRoute);
router.use(authenticated);
router.use("/profile", profileRoute);
router.use("/coach", coachRoute);
export default router;