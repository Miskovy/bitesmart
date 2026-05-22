import { Router } from "express";
import catchAsync from "../../utils/catchAsync";
import multer from "multer";
import {
    getProfileData,
    updateProfileData,
    enableMode,
    calculateAndSaveTargets,
    updateDeviceSettingsController,
    syncHealthDataController,
    uploadAvatarController
} from "../../controllers/user/profile.controller";

const router = Router();
const upload = multer();


router.get("/", catchAsync(getProfileData));
router.put("/", catchAsync(updateProfileData));
router.patch("/mode", catchAsync(enableMode));
//! Created by Antigravity: Route to calculate and save targets based on goal
router.post("/targets/calculate", catchAsync(calculateAndSaveTargets));

//! Created by Antigravity: Routes for device settings and health sync
router.patch("/device-settings", catchAsync(updateDeviceSettingsController));
router.post("/health-sync", catchAsync(syncHealthDataController));

//! Created by Antigravity: Route for avatar upload
router.post("/avatar", upload.single("avatar"), catchAsync(uploadAvatarController));

export default router;