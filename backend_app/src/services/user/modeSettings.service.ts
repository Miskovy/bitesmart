import { eq } from "drizzle-orm";
import { db } from "../../db/connection";
import { userDietaryPreferences } from "../../models/user_dietary_preferences";
import { BadRequest } from "../../errors";

//! Created by Antigravity: Service to save full GLP-1 settings bundle
export const saveGlp1Settings = async (
    userId: string,
    settings: {
        highProteinGoal?: boolean;
        hydrationReminderHours?: number;
    }
) => {
    const updates: Partial<typeof userDietaryPreferences.$inferInsert> = {
        isGlp1User: true,
    };

    if (settings.highProteinGoal !== undefined) {
        updates.highProteinGoal = settings.highProteinGoal;
    }
    if (settings.hydrationReminderHours !== undefined) {
        if (settings.hydrationReminderHours < 1 || settings.hydrationReminderHours > 8) {
            throw new BadRequest("Hydration reminder interval must be between 1 and 8 hours");
        }
        updates.hydrationReminderHours = settings.hydrationReminderHours;
    }

    const existing = await db.query.userDietaryPreferences.findFirst({
        where: eq(userDietaryPreferences.userId, userId)
    });

    if (existing) {
        await db.update(userDietaryPreferences)
            .set(updates)
            .where(eq(userDietaryPreferences.userId, userId));
    } else {
        await db.insert(userDietaryPreferences).values({
            userId,
            ...updates,
        });
    }

    // Return the updated preferences
    const updated = await db.query.userDietaryPreferences.findFirst({
        where: eq(userDietaryPreferences.userId, userId)
    });

    return {
        message: "GLP-1 settings saved successfully",
        settings: updated,
    };
};

//! Created by Antigravity: Service to save full Ramadan Mode settings bundle
export const saveRamadanSettings = async (
    userId: string,
    settings: {
        suhoorTime?: string;
        iftarTime?: string;
        hydrationFocus?: boolean;
    }
) => {
    const updates: Partial<typeof userDietaryPreferences.$inferInsert> = {
        isRamadanMode: true,
    };

    if (settings.suhoorTime !== undefined) {
        updates.suhoorTime = settings.suhoorTime;
    }
    if (settings.iftarTime !== undefined) {
        updates.iftarTime = settings.iftarTime;
    }
    if (settings.hydrationFocus !== undefined) {
        updates.hydrationFocus = settings.hydrationFocus;
    }

    const existing = await db.query.userDietaryPreferences.findFirst({
        where: eq(userDietaryPreferences.userId, userId)
    });

    if (existing) {
        await db.update(userDietaryPreferences)
            .set(updates)
            .where(eq(userDietaryPreferences.userId, userId));
    } else {
        await db.insert(userDietaryPreferences).values({
            userId,
            ...updates,
        });
    }

    // Return the updated preferences
    const updated = await db.query.userDietaryPreferences.findFirst({
        where: eq(userDietaryPreferences.userId, userId)
    });

    return {
        message: "Ramadan Mode settings saved successfully",
        settings: updated,
    };
};
