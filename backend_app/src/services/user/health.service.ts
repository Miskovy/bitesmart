import { eq, and } from "drizzle-orm";
import { db } from "../../db/connection";
import { healthSync } from "../../models/health_sync";
import { users } from "../../models/user";
import { BadRequest } from "../../errors";

//! Created by Antigravity: Service to sync health data from Apple Health / Google Fit
export const syncHealthData = async (userId: string, activeCaloriesBurned: number, steps: number, dateStr: string) => {
    // Ensure the user has health data sync enabled
    const user = await db.query.users.findFirst({
        where: eq(users.id, userId)
    });

    if (!user?.healthDataEnabled) {
        throw new BadRequest("Health data sync is not enabled for this user.");
    }

    const syncDateObj = new Date(dateStr);

    // Check if there is already a record for today
    const existingLog = await db.query.healthSync.findFirst({
        where: and(
            eq(healthSync.userId, userId),
            eq(healthSync.syncDate, syncDateObj)
        )
    });

    if (existingLog) {
        // Update the existing record
        await db.update(healthSync)
            .set({
                activeCaloriesBurned,
                steps
            })
            .where(eq(healthSync.id, existingLog.id));
    } else {
        // Create a new record for today
        await db.insert(healthSync).values({
            userId,
            activeCaloriesBurned,
            steps,
            syncDate: syncDateObj
        });
    }

    return {
        message: "Health data synced successfully",
        syncedData: {
            date: dateStr,
            activeCaloriesBurned,
            steps
        }
    };
};
