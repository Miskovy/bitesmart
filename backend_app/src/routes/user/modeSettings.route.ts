import { Router } from "express";
import catchAsync from "../../utils/catchAsync";
import { 
    getGlp1SettingsController,
    saveGlp1SettingsController, 
    getFastingSettingsController,
    saveFastingSettingsController,
    saveRamadanSettingsController 
} from "../../controllers/user/modeSettings.controller";

const router = Router();

//! Created by Antigravity: Routes for GLP-1 and Fasting mode settings
router.get("/glp1", catchAsync(getGlp1SettingsController));
router.put("/glp1", catchAsync(saveGlp1SettingsController));
router.get("/fasting", catchAsync(getFastingSettingsController));
router.put("/fasting", catchAsync(saveFastingSettingsController));
//! Created by Antigravity: Legacy route mapping for Ramadan Mode
router.put("/ramadan", catchAsync(saveRamadanSettingsController));

export default router;
