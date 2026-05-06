import { Request, Response, NextFunction } from "express";
import { getMyProfile, updatemyProfile } from "../../services/user/profile.service";
import { BadRequest } from "../../errors";

// TODO: Profile
export const getProfileData = async (req: Request, res: Response, next: NextFunction) => {
  try {
    // Extract userId from the authenticated request
    const userId = (req as any).user?.id; 

    if (!userId) {
      throw new BadRequest("User ID is missing or user is not authenticated");
    }

    const profileData = await updatemyProfile(userId,req.body);

    return res.status(200).json({
      success: true,
      message: "Profile retrieved successfully",
      data: profileData,
    });
  } catch (error) {
    next(error);
  }
};


export const updateProfileData = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = (req as any).user?.id;

    if (!userId) {
      throw new BadRequest("User ID is missing or user is not authenticated");
    }

    if (!req.body || Object.keys(req.body).length === 0) {
      throw new BadRequest("Update payload cannot be empty");
    }

    // Pass the userId and the request body to the service layer
    const updatedProfile = await updatemyProfile(userId, req.body);

    return res.status(200).json({
      success: true,
      message: "Profile updated successfully",
      data: updatedProfile,
    });
  } catch (error) {
    next(error);
  }
};

// Enable Mode: GLP-1 or Ramadan Mode
export const enableMode = async (req: Request, res: Response) => {};