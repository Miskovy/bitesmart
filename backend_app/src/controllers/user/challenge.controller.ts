import { Request, Response } from "express";
import { getChallenges, joinChallenge, leaveChallenge, updateChallengeProgress } from "../../services/user/challenge.service";
import { BadRequest, UnauthorizedError } from "../../errors";
import { SuccessResponse } from "../../utils/Response";

//! Created by Antigravity: Controller to get all community challenges with user join status and progress
export const getChallengesController = async (req: Request, res: Response) => {
    const userId = req.user?.id;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    const challenges = await getChallenges(userId);
    SuccessResponse(res, challenges, 200);
};

//! Created by Antigravity: Controller to join a community challenge
export const joinChallengeController = async (req: Request, res: Response) => {
    const userId = req.user?.id;
    const { challengeId } = req.params;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    if (!challengeId) {
        throw new BadRequest("Challenge ID is required");
    }

    const result = await joinChallenge(userId, challengeId as string);
    SuccessResponse(res, result, 201);
};

//! Created by Antigravity: Controller to leave a community challenge
export const leaveChallengeController = async (req: Request, res: Response) => {
    const userId = req.user?.id;
    const { challengeId } = req.params;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    if (!challengeId) {
        throw new BadRequest("Challenge ID is required");
    }

    const result = await leaveChallenge(userId, challengeId as string);
    SuccessResponse(res, result, 200);
};

//! Created by Antigravity: Controller to update user's progress in a challenge
export const updateChallengeProgressController = async (req: Request, res: Response) => {
    const userId = req.user?.id;
    const { challengeId } = req.params;
    const { progress } = req.body;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    if (!challengeId) {
        throw new BadRequest("Challenge ID is required");
    }

    if (progress === undefined) {
        throw new BadRequest("Progress is required");
    }

    const result = await updateChallengeProgress(userId, challengeId as string, Number(progress));
    SuccessResponse(res, result, 200);
};
