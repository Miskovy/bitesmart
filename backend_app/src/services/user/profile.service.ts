import { eq } from "drizzle-orm";
import { db } from "../../db/connection";
import { users } from "../../models/user";
import { userMedicalConditions } from "../../models/user_medical_conditions";
import { userDietaryPreferences } from "../../models/user_dietary_preferences";
import { userTarget } from "../../models/user_target";
import { NotFound } from "../../errors";
import { userModes } from "../../types/interfaces";

// TODO: Complete the profile services

// --- INTERFACES ---

export interface UpdateProfileData {
    // Core User Fields (Excludes id, email, password, googleId, etc.)
    name?: string;
    avatar?: string;
    height?: number;
    weight?: number;
    BMI?: number;
    gender?: "Male" | "Female";
    age?: number;
    activityLevel?: "Sedentary" | "LightlyActive" | "ModeratelyActive" | "VeryActive";
    userGoal?: "WeightLoss" | "Maintenance" | "MuscleGain";

    // Related Tables
    medicalConditions?: {
        isDiabetesType1?: boolean;
        isDiabetesType2?: boolean;
        isHypertension?: boolean;
        isPCOS?: boolean;
        isAnemia?: boolean;
        isCeliacDisease?: boolean;
        isIBS?: boolean;
    };

    dietaryPreferences?: {
        isVegetarian?: boolean;
        isVegan?: boolean;
        isKeto?: boolean;
        isPaleo?: boolean;
        isGlutenFree?: boolean;
        isHalal?: boolean;
        isPescatarian?: boolean;
        isGlp1User?: boolean;
    };

    targets?: {
        calTotal?: number;
        proteins?: number;
        carbs?: number;
        fats?: number;
        iron_mg?: number;
        sodium_mg?: number;
        vitamin_d_iu?: number;
        water_ml?: number;
    };
}

// --- SERVICES ---

export const getMyProfile = async (userId: string) => {
    // 1. Fetch the main user record
    const user = await db.query.users.findFirst({
        where: eq(users.id, userId),
    });

    if (!user) {
        throw new NotFound("User profile not found");
    }

    // Strip out sensitive fields before returning
    const { password, ...safeUser } = user;

    // 2. Fetch related profile tables concurrently for performance
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

    // 3. Return unified profile
    return {
        ...safeUser,
        medicalConditions: medicalConditions || null,
        dietaryPreferences: dietaryPreferences || null,
        targets: targets || null,
    };
};
// Be Sure to make an interface for the data , and remove 'any'
export const updatemyProfile = async (userId: string, data: UpdateProfileData) => {
    // 1. Destructure the typed payload
    const { medicalConditions, dietaryPreferences, targets, ...userCoreData } = data;

    const updatePromises = [];

    // 2. Queue Core User Updates
    if (Object.keys(userCoreData).length > 0) {
        updatePromises.push(
            db.update(users)
                .set(userCoreData)
                .where(eq(users.id, userId))
        );
    }

    // 3. Queue Medical Conditions Updates
    if (medicalConditions && Object.keys(medicalConditions).length > 0) {
        updatePromises.push(
            db.update(userMedicalConditions)
                .set(medicalConditions)
                .where(eq(userMedicalConditions.userId, userId))
        );
    }

    // 4. Queue Dietary Preferences Updates
    if (dietaryPreferences && Object.keys(dietaryPreferences).length > 0) {
        updatePromises.push(
            db.update(userDietaryPreferences)
                .set(dietaryPreferences)
                .where(eq(userDietaryPreferences.userId, userId))
        );
    }

    // 5. Queue Nutrition Targets Updates
    if (targets && Object.keys(targets).length > 0) {
        updatePromises.push(
            db.update(userTarget)
                .set(targets)
                .where(eq(userTarget.userId, userId))
        );
    }

    // 6. Execute all queued updates concurrently
    if (updatePromises.length > 0) {
        await Promise.all(updatePromises);
    }

    // 7. Return the freshly updated profile using the getter we already built
    return await getMyProfile(userId);
};
export const enableMode = async (mode: userModes) => { };
