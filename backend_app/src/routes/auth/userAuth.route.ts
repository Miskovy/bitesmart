import { Router } from "express";
import catchAsync from "../../utils/catchAsync";
import {
  userLogin,
  signup,
  googleAuth,
  forgotPasswordController,
  verifyResetCodeController,
  resetPasswordController,
  adminLoginController,
} from "../../controllers/auth/userAuth.controller";

const router = Router();
router.post("/adminlogin", catchAsync(adminLoginController));
router.post("/login", catchAsync(userLogin));
router.post("/signup", catchAsync(signup));
router.post("/google", catchAsync(googleAuth));
router.post("/forgot-password", catchAsync(forgotPasswordController));
router.post("/verify-reset-code", catchAsync(verifyResetCodeController));
router.post("/reset-password", catchAsync(resetPasswordController));

export default router;
