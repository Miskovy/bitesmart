import { Router } from "express";
import catchAsync from "../../utils/catchAsync";
import { userLogin, signup, googleAuth } from "../../controllers/auth/userAuth.controller";

const router = Router();

router.post("/login", catchAsync(userLogin));
router.post("/signup", catchAsync(signup));
router.post("/google", catchAsync(googleAuth));

export default router;