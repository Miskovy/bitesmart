import { Router } from "express";
import catchAsync from "../../utils/catchAsync";
import { saveGlp1SettingsController, saveRamadanSettingsController } from "../../controllers/user/modeSettings.controller";

const router = Router();

//! Created by Antigravity: Routes for GLP-1 and Ramadan mode settings
router.put("/glp1", catchAsync(saveGlp1SettingsController));
router.put("/ramadan", catchAsync(saveRamadanSettingsController));

export default router;
