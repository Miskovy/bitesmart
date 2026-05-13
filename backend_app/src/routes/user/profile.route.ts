import { Router } from "express";
import catchAsync from "../../utils/catchAsync";
import { getProfileData, updateProfileData, enableMode } from "../../controllers/user/profile.controller";

const router = Router();


router.get("/", catchAsync(getProfileData));
router.put("/", catchAsync(updateProfileData));
router.patch("/mode", catchAsync(enableMode));

export default router;