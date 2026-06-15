import { Request, Response } from "express";
import { getInsights, Period } from "../../services/user/insights.service";
import { BadRequest, UnauthorizedError } from "../../errors";
import { SuccessResponse } from "../../utils/Response";

/**
 * Controller to fetch dietary and weight insights for the authenticated user.
 */
export const getInsightsController = async (req: Request, res: Response) => {
  const userId = req.user?.id;
  if (!userId) {
    throw new UnauthorizedError("User is not authenticated");
  }

  const { period } = req.query;

  if (!period || (period !== Period.Weekly && period !== Period.Monthly)) {
    throw new BadRequest("Period query parameter must be either 'Weekly' or 'Monthly'");
  }

  const timezone = req.headers["x-timezone"] as string | undefined;
  const offsetHeader = req.headers["x-timezone-offset"];
  const offsetMinutes = offsetHeader ? Number(offsetHeader) : undefined;

  const result = await getInsights(
    userId,
    period as Period,
    timezone,
    offsetMinutes
  );

  SuccessResponse(res, result, 200);
};
