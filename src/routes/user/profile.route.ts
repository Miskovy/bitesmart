import { Router } from "express";
import catchAsync from "../../utils/catchAsync";
import { getProfileData, updateProfileData } from "../../controllers/user/profile.controller";

const router = Router();


router.get("/", catchAsync(getProfileData));
router.put("/", catchAsync(updateProfileData));

export default router;