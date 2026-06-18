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
    uploadAvatarController,
    triggerFastingDaemonController
} from "../../controllers/user/profile.controller";

const router = Router();
const upload = multer();


router.get("/", catchAsync(getProfileData));
router.put("/", catchAsync(updateProfileData));
router.patch("/mode", catchAsync(enableMode));
router.post("/targets/calculate", catchAsync(calculateAndSaveTargets));
router.patch("/device-settings", catchAsync(updateDeviceSettingsController));
router.post("/health-sync", catchAsync(syncHealthDataController));
router.post("/avatar", upload.single("avatar"), catchAsync(uploadAvatarController));
router.post("/fasting-daemon/trigger", catchAsync(triggerFastingDaemonController));

export default router;