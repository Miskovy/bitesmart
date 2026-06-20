import { Request, Response } from "express";
import { getAdminDashboardData } from "../../services/user/dashboard.service";
import { SuccessResponse } from "../../utils/Response";

/**
 * Controller to fetch admin dashboard stats and insights.
 */
export const getDashboardController = async (req: Request, res: Response) => {
    const result = await getAdminDashboardData();
    SuccessResponse(res, result, 200);
};
