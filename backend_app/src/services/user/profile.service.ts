import { eq } from "drizzle-orm";
import { db } from "../../db/connection";
import { users } from "../../models/user";
import { userMedicalConditions } from "../../models/user_medical_conditions";
import { userDietaryPreferences } from "../../models/user_dietary_preferences";
import { userTarget } from "../../models/user_target";
import { NotFound } from "../../errors";
import { userModes } from "../../types/interfaces";
import { UpdateProfileData } from "../../types/interfaces";

export const getMyProfile = async (userId: string) => {

    const user = await db.query.users.findFirst({
        where: eq(users.id, userId),
    });

    if (!user) {
        throw new NotFound("User profile not found");
    }

    const { password, ...safeUser } = user;

    const [medicalConditions, dietaryPreferences, targets] = await Promise.all([
        db.query.userMedicalConditions.findFirst({
            where: eq(userMedicalConditions.userId, userId),
        }),
        db.query.userDietaryPreferences.findFirst({
            where: eq(userDietaryPreferences.userId, userId),
        }),
        db.query.userTarget.findFirst({
            where: eq(userTarget.userId, userId),
        })
    ]);

    return {
        ...safeUser,
        medicalConditions: medicalConditions || null,
        dietaryPreferences: dietaryPreferences || null,
        targets: targets || null,
    };
};

export const updatemyProfile = async (userId: string, data: UpdateProfileData) => {
    const { medicalConditions, dietaryPreferences, targets, ...userCoreData } = data;

    const updatePromises = [];

    if (Object.keys(userCoreData).length > 0) {
        updatePromises.push(
            db.update(users)
                .set(userCoreData)
                .where(eq(users.id, userId))
        );
    }

    if (medicalConditions && Object.keys(medicalConditions).length > 0) {
        updatePromises.push(
            db.update(userMedicalConditions)
                .set(medicalConditions)
                .where(eq(userMedicalConditions.userId, userId))
        );
    }

    if (dietaryPreferences && Object.keys(dietaryPreferences).length > 0) {
        updatePromises.push(
            db.update(userDietaryPreferences)
                .set(dietaryPreferences)
                .where(eq(userDietaryPreferences.userId, userId))
        );
    }

    if (targets && Object.keys(targets).length > 0) {
        updatePromises.push(
            db.update(userTarget)
                .set(targets)
                .where(eq(userTarget.userId, userId))
        );
    }

    if (updatePromises.length > 0) {
        await Promise.all(updatePromises);
    }

    return await getMyProfile(userId);
};
export const enableMode = async (userId: string, mode: userModes) => {
    const updates: Partial<typeof userDietaryPreferences.$inferInsert> = {};

    if (mode.glp1 !== undefined) {
        updates.isGlp1User = mode.glp1;
    }
    if (mode.ramadanMode !== undefined) {
        updates.isRamadanMode = mode.ramadanMode;
    }

    if (Object.keys(updates).length > 0) {
        const existing = await db.query.userDietaryPreferences.findFirst({
            where: eq(userDietaryPreferences.userId, userId)
        });

        if (existing) {
            await db.update(userDietaryPreferences)
                .set(updates)
                .where(eq(userDietaryPreferences.userId, userId));
        } else {
            await db.insert(userDietaryPreferences)
                .values({
                    userId,
                    ...updates
                });
        }
    }

    return await getMyProfile(userId);
};

//! Created by Antigravity: Service to update device settings (Notifications, Health Data, Camera Access, Device Token)
export const updateDeviceSettings = async (
    userId: string, 
    settings: { notificationsEnabled?: boolean; healthDataEnabled?: boolean; cameraAccessEnabled?: boolean; deviceToken?: string }
) => {
    const updates: Partial<typeof users.$inferInsert> = {};

    if (settings.notificationsEnabled !== undefined) {
        updates.notificationsEnabled = settings.notificationsEnabled;
    }
    if (settings.healthDataEnabled !== undefined) {
        updates.healthDataEnabled = settings.healthDataEnabled;
    }
    if (settings.cameraAccessEnabled !== undefined) {
        updates.cameraAccessEnabled = settings.cameraAccessEnabled;
    }
    if (settings.deviceToken !== undefined) {
        updates.deviceToken = settings.deviceToken;
    }

    if (Object.keys(updates).length > 0) {
        await db.update(users)
            .set(updates)
            .where(eq(users.id, userId));
    }

    return await getMyProfile(userId);
};
