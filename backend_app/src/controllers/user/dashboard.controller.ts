import { Request, Response } from "express";
import { getUserDashboardData } from "../../services/user/dashboard.service";
import { UnauthorizedError } from "../../errors";
import { SuccessResponse } from "../../utils/Response";

/**
 * Controller to fetch home dashboard stats and insights for the authenticated user.
 */
export const getDashboardController = async (req: Request, res: Response) => {
    const userId = req.user?.id;
    if (!userId) {
        throw new UnauthorizedError("User is not authenticated");
    }

    const timezone = req.headers["x-timezone"] as string | undefined;
    const offsetHeader = req.headers["x-timezone-offset"];
    const offsetMinutes = offsetHeader ? Number(offsetHeader) : undefined;

    const result = await getUserDashboardData(userId, timezone, offsetMinutes);
    SuccessResponse(res, result, 200);
};
