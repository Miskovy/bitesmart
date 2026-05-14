import { Request, Response } from "express";
import { getMyProfile, updatemyProfile } from "../../services/user/profile.service";
import { BadRequest } from "../../errors";
import { SuccessResponse } from "../../utils/Response";


export const getProfileData = async (req: Request, res: Response) => {
  try {
    const userId = req.user?.id; 
    if (!userId) {
      throw new BadRequest("User ID is missing or user is not authenticated");
    }
    const profileData = await getMyProfile(userId);

    SuccessResponse(res, profileData, 200);

  } catch (error) {
    throw new BadRequest("Failed to retrieve profile data");
  }
};


export const updateProfileData = async (req: Request, res: Response) => {
  try {
    const userId = req.user?.id;

    if (!userId) {
      throw new BadRequest("User ID is missing or user is not authenticated");
    }

    if (!req.body || Object.keys(req.body).length === 0) {
      throw new BadRequest("Update payload cannot be empty");
    }

    const updatedProfile = await updatemyProfile(userId, req.body);

    SuccessResponse(res, updatedProfile, 200);

  } catch (error) {
    throw new BadRequest("Failed to update profile data");
  }
};

// Enable Mode: GLP-1 or Ramadan Mode
export const enableMode = async (req: Request, res: Response) => {
  try {
    const userId = req.user?.id;

    if (!userId) {
      throw new BadRequest("User ID is missing or user is not authenticated");
    }

    const { glp1, ramadanMode } = req.body;

    if (glp1 === undefined && ramadanMode === undefined) {
      throw new BadRequest("Must provide glp1 or ramadanMode in the request body");
    }

    const { enableMode: enableModeService } = await import("../../services/user/profile.service");
    const updatedProfile = await enableModeService(userId, { glp1, ramadanMode });

    SuccessResponse(res, updatedProfile, 200);

  } catch (error: any) {
    throw new BadRequest(error.message || "Failed to update mode");
  }
};

//! Created by Antigravity: Controller to trigger target calculation
export const calculateAndSaveTargets = async (req: Request, res: Response) => {
  try {
    const userId = req.user?.id;

    if (!userId) {
      throw new BadRequest("User ID is missing or user is not authenticated");
    }

    const { calculateUserTargets } = await import("../../services/user/target.service");
    const targets = await calculateUserTargets(userId);

    SuccessResponse(res, targets, 200);

  } catch (error: any) {
    throw new BadRequest(error.message || "Failed to calculate targets");
  }
};

//! Created by Antigravity: Controller to update device settings (Notifications, Health Data, Camera Access)
export const updateDeviceSettingsController = async (req: Request, res: Response) => {
  try {
    const userId = req.user?.id;

    if (!userId) {
      throw new BadRequest("User ID is missing or user is not authenticated");
    }

    const { notificationsEnabled, healthDataEnabled, cameraAccessEnabled, deviceToken } = req.body;

    const { updateDeviceSettings } = await import("../../services/user/profile.service");
    const updatedProfile = await updateDeviceSettings(userId, { notificationsEnabled, healthDataEnabled, cameraAccessEnabled, deviceToken });

    SuccessResponse(res, updatedProfile, 200);

  } catch (error: any) {
    throw new BadRequest(error.message || "Failed to update device settings");
  }
};

//! Created by Antigravity: Controller to sync Apple Health / Google Fit data
export const syncHealthDataController = async (req: Request, res: Response) => {
  try {
    const userId = req.user?.id;

    if (!userId) {
      throw new BadRequest("User ID is missing or user is not authenticated");
    }

    const { activeCaloriesBurned, steps, dateStr } = req.body;

    if (activeCaloriesBurned === undefined || steps === undefined || !dateStr) {
        throw new BadRequest("activeCaloriesBurned, steps, and dateStr are required.");
    }

    const { syncHealthData } = await import("../../services/user/health.service");
    const result = await syncHealthData(userId, activeCaloriesBurned, steps, dateStr);

    SuccessResponse(res, result, 200);

  } catch (error: any) {
    throw new BadRequest(error.message || "Failed to sync health data");
  }
};

//! Created by Antigravity: Controller to upload user avatar
export const uploadAvatarController = async (req: Request, res: Response) => {
  try {
    const userId = req.user?.id;

    if (!userId) {
      throw new BadRequest("User ID is missing or user is not authenticated");
    }

    if (!req.file) {
      throw new BadRequest("No image file provided");
    }

    const { uploadAvatar } = await import("../../services/user/avatar.service");
    const result = await uploadAvatar(userId, req.file);

    SuccessResponse(res, result, 200);

  } catch (error: any) {
    throw new BadRequest(error.message || "Failed to upload avatar");
  }
};