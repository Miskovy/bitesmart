import { Request, Response, NextFunction } from "express";
import { db } from "../db/connection";
import { users } from "../models/user";
import { eq } from "drizzle-orm";
import { UnauthorizedError } from "../errors";

/**
 * Middleware to check if the authenticated user has Admin privileges.
 */
export const isAdmin = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const userId = req.user?.id;
        if (!userId) {
            throw new UnauthorizedError("User is not authenticated");
        }

        // Fetch the user role from the database
        const user = await db.query.users.findFirst({
            where: eq(users.id, userId),
            columns: {
                role: true,
            },
        });

        if (!user || user.role !== "Admin") {
            throw new UnauthorizedError("Forbidden: Admin privileges required");
        }

        next();
    } catch (error) {
        next(error);
    }
};
