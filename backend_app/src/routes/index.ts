import { Router } from "express";
import foodRoute from "./food/food.route";
import authRoute from "./auth/userAuth.route";

const router = Router();

router.use("/login", authRoute);
router.use("/food", foodRoute);

export default router;