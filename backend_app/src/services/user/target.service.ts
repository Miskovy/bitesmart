import { eq } from "drizzle-orm";
import { db } from "../../db/connection";
import { users } from "../../models/user";
import { userDietaryPreferences } from "../../models/user_dietary_preferences";
import { userTarget } from "../../models/user_target";
import { BadRequest, NotFound } from "../../errors";

//! Created by Antigravity: Function to calculate Basal Metabolic Rate (BMR) using Mifflin-St Jeor equation
const calculateBMR = (weight: number, height: number, age: number, gender: "Male" | "Female") => {
    if (gender === "Male") {
        return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
        return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
};

//! Created by Antigravity: Function to calculate Total Daily Energy Expenditure (TDEE) based on activity level
const calculateTDEE = (bmr: number, activityLevel: string) => {
    switch (activityLevel) {
        case 'Sedentary': return bmr * 1.2;
        case 'LightlyActive': return bmr * 1.375;
        case 'ModeratelyActive': return bmr * 1.55;
        case 'VeryActive': return bmr * 1.725;
        default: return bmr * 1.2;
    }
};

//! Created by Antigravity: Core service to calculate and save user nutrition targets based on goals and clinical modes (GLP-1)
export const calculateUserTargets = async (userId: string) => {
    const user = await db.query.users.findFirst({
        where: eq(users.id, userId)
    });

    if (!user) {
        throw new NotFound("User not found");
    }

    if (!user.weight || !user.height || !user.age || !user.gender || !user.activityLevel || !user.userGoal) {
        throw new BadRequest("Incomplete user profile. Weight, height, age, gender, activity level, and goal are required to calculate targets.");
    }

    const dietaryPrefs = await db.query.userDietaryPreferences.findFirst({
        where: eq(userDietaryPreferences.userId, userId)
    });

    const isGlp1User = dietaryPrefs?.isGlp1User || false;

    // 1. Calculate BMR and TDEE
    const bmr = calculateBMR(user.weight, user.height, user.age, user.gender);
    const tdee = calculateTDEE(bmr, user.activityLevel);

    // 2. Adjust Calories Based on Goal
    let targetCalories = tdee;
    if (user.userGoal === "WeightLoss") {
        targetCalories -= 500;
    } else if (user.userGoal === "MuscleGain") {
        targetCalories += 300;
    }

    // Minimum safe calorie limit
    if (targetCalories < 1200) targetCalories = 1200;

    // 3. Calculate Macronutrients
    let proteinGrams = 0;
    let fatGrams = 0;
    let carbGrams = 0;
    let waterMl = 2000; // default water

    if (isGlp1User) {
        // GLP-1 Clinical Override:
        // High protein to prevent muscle loss (sarcopenia) - 2.0g per kg of body weight
        // Hydration boost to prevent dehydration
        proteinGrams = user.weight * 2.0;
        waterMl = 3000; // GLP-1 users need more hydration
        
        const proteinCalories = proteinGrams * 4;
        // Fats are kept moderate (25% of total calories) to avoid gastrointestinal side effects common with GLP-1
        const fatCalories = targetCalories * 0.25;
        fatGrams = fatCalories / 9;
        
        // Remainder is carbs
        const carbCalories = targetCalories - proteinCalories - fatCalories;
        carbGrams = carbCalories > 0 ? carbCalories / 4 : 0;
    } else {
        // Standard Macros
        if (user.userGoal === "WeightLoss") {
            // 40% Protein, 30% Fat, 30% Carbs
            proteinGrams = (targetCalories * 0.4) / 4;
            fatGrams = (targetCalories * 0.3) / 9;
            carbGrams = (targetCalories * 0.3) / 4;
            waterMl = 2500;
        } else if (user.userGoal === "MuscleGain") {
            // 30% Protein, 25% Fat, 45% Carbs
            proteinGrams = (targetCalories * 0.3) / 4;
            fatGrams = (targetCalories * 0.25) / 9;
            carbGrams = (targetCalories * 0.45) / 4;
            waterMl = 3000;
        } else {
            // Maintenance: 25% Protein, 30% Fat, 45% Carbs
            proteinGrams = (targetCalories * 0.25) / 4;
            fatGrams = (targetCalories * 0.3) / 9;
            carbGrams = (targetCalories * 0.45) / 4;
            waterMl = 2500;
        }
    }

    // Prepare target payload
    const targets = {
        userId,
        calTotal: Math.round(targetCalories),
        proteins: Math.round(proteinGrams),
        fats: Math.round(fatGrams),
        carbs: Math.round(carbGrams),
        water_ml: waterMl,
        //! Created by Antigravity: Set autoCalculateWithAi to true when auto-calculating
        autoCalculateWithAi: true
    };

    // 4. Save to Database (Upsert)
    const existingTarget = await db.query.userTarget.findFirst({
        where: eq(userTarget.userId, userId)
    });

    if (existingTarget) {
        await db.update(userTarget)
            .set(targets)
            .where(eq(userTarget.userId, userId));
    } else {
        await db.insert(userTarget).values(targets);
    }

    return targets;
};
