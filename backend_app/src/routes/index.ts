import { Router } from "express";
import foodRoute from "./food/food.route";
import authRoute from "./auth/userAuth.route";
import predictionRoute from "./food/prediction.route";

const router = Router();

router.use("/login", authRoute);
router.use("/food", foodRoute);
router.use("/prediction", predictionRoute);
export default router;