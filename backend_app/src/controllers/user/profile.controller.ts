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