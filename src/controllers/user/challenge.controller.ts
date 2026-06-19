import { Request, Response } from "express";
import {
    getChallenges,
    joinChallenge,
    leaveChallenge,
    updateChallengeProgress,
    createChallenge,
    getAllChallengesAdmin,
    getChallengeByIdAdmin,
    updateChallenge,
    deleteChallenge,
} from "../../services/user/challenge.service";
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

export const createChallengeController = async (req: Request, res: Response) => {
    const { title, description, startDate, endDate } = req.body;

    if (!title || !description) {
        throw new BadRequest("Title and Description are required");
    }

    const result = await createChallenge(title, description, startDate, endDate);
    SuccessResponse(res, result, 201);
};

/* ==========================================
   ADMINISTRATIVE CHALLENGES CRUD CONTROLLERS
   ========================================== */

/**
 * Controller to fetch all community challenges with pagination/search for admin
 */
export const getAllChallengesAdminController = async (req: Request, res: Response) => {
    const page = req.query.page ? Number(req.query.page) : 1;
    const pageSize = req.query.pageSize ? Number(req.query.pageSize) : 10;
    const query = req.query.query as string | undefined;

    const result = await getAllChallengesAdmin({ page, pageSize, query });
    SuccessResponse(res, result, 200);
};

/**
 * Controller to fetch a specific community challenge for admin
 */
export const getChallengeByIdAdminController = async (req: Request, res: Response) => {
    const { id } = req.params;
    if (!id) {
        throw new BadRequest("Challenge ID is required");
    }

    const result = await getChallengeByIdAdmin(id as string);
    SuccessResponse(res, result, 200);
};

/**
 * Controller to update a community challenge
 */
export const updateChallengeController = async (req: Request, res: Response) => {
    const { id } = req.params;
    if (!id) {
        throw new BadRequest("Challenge ID is required");
    }

    const result = await updateChallenge(id as string, req.body);
    SuccessResponse(res, result, 200);
};

/**
 * Controller to delete a community challenge and clean participants
 */
export const deleteChallengeController = async (req: Request, res: Response) => {
    const { id } = req.params;
    if (!id) {
        throw new BadRequest("Challenge ID is required");
    }

    const result = await deleteChallenge(id as string);
    SuccessResponse(res, result, 200);
};
