import { Request, Response } from "express";
import { getLeaderboardData } from "../../services/user/leaderboard.service";
import { UnauthorizedError } from "../../errors";
import { SuccessResponse } from "../../utils/Response";

//! Created by Antigravity: Controller to retrieve global and friends leaderboard rankings
export const getLeaderboardController = async (req: Request, res: Response) => {
    const userId = req.user?.id;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    const leaderboard = await getLeaderboardData(userId);
    SuccessResponse(res, leaderboard, 200);
};
