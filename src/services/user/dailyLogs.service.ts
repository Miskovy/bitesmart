import { eq, and, gte, lte, sql } from "drizzle-orm";
import { db } from "../../db/connection";
import { dailyLogs } from "../../models/daily_logs";
import { foodItems } from "../../models/food_items";
import { userTarget } from "../../models/user_target";
//! Created by Antigravity: Import water logs model
import { waterLogs } from "../../models/water_logs";
//! Created by Antigravity: Import completed days and user models
import { completedDays } from "../../models/completed_days";
import { users } from "../../models/user";
import { BadRequest, NotFound } from "../../errors";

//! Created by Antigravity: Service to log a meal into the user's daily logs
export const logMeal = async (
    userId: string,
    foodItemId: number,
    mealType: "Breakfast" | "Lunch" | "Dinner" | "Snack",
    quantity: number,
    unit?: string,
    imageUrl?: string
) => {
    // Verify the food item exists
    const food = await db.query.foodItems.findFirst({
        where: eq(foodItems.id, foodItemId)
    });

    if (!food) {
        throw new NotFound("Food item not found");
    }

    // Insert the log
    const newLog = await db.insert(dailyLogs).values({
        userId,
        foodItemId,
        mealType,
        quantity,
        unit: unit || "g",
        imageUrl: imageUrl || null,
    });

    // Calculate the actual nutrition for this serving
    const factor = quantity / 100;
    const loggedNutrition = {
        calories: Math.round(food.cals_per_100g * factor),
        protein: Math.round(food.protein_per_100g * factor),
        carbs: Math.round(food.carbs_per_100g * factor),
        fats: Math.round(food.fats_per_100g * factor),
    };

    return {
        message: "Meal logged successfully",
        foodName: food.class_name,
        mealType,
        quantity,
        unit: unit || "g",
        nutrition: loggedNutrition,
    };
};

//! Created by Antigravity: Service to delete a meal log entry
export const deleteMealLog = async (userId: string, logId: string) => {
    const existingLog = await db.query.dailyLogs.findFirst({
        where: and(
            eq(dailyLogs.id, logId),
            eq(dailyLogs.userId, userId)
        )
    });

    if (!existingLog) {
        throw new NotFound("Log entry not found or does not belong to this user");
    }

    await db.delete(dailyLogs).where(eq(dailyLogs.id, logId));

    return { message: "Log entry deleted successfully" };
};

//! Created by Antigravity: Service to get all meal logs for a specific date
export const getMealLogsByDate = async (userId: string, dateStr: string) => {
    // Build start and end of the day in UTC
    const startOfDay = new Date(dateStr);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(dateStr);
    endOfDay.setHours(23, 59, 59, 999);

    const logs = await db
        .select({
            logId: dailyLogs.id,
            mealType: dailyLogs.mealType,
            quantity: dailyLogs.quantity,
            unit: dailyLogs.unit,
            imageUrl: dailyLogs.imageUrl,
            loggedAt: dailyLogs.loggedAt,
            foodItemId: foodItems.id,
            foodName: foodItems.class_name,
            cals_per_100g: foodItems.cals_per_100g,
            protein_per_100g: foodItems.protein_per_100g,
            carbs_per_100g: foodItems.carbs_per_100g,
            fats_per_100g: foodItems.fats_per_100g,
        })
        .from(dailyLogs)
        .leftJoin(foodItems, eq(dailyLogs.foodItemId, foodItems.id))
        .where(
            and(
                eq(dailyLogs.userId, userId),
                gte(dailyLogs.loggedAt, startOfDay),
                lte(dailyLogs.loggedAt, endOfDay)
            )
        );

    // Enrich each log with calculated nutrition
    const enrichedLogs = logs.map((log) => {
        const factor = (log.quantity || 0) / 100;
        return {
            logId: log.logId,
            mealType: log.mealType,
            quantity: log.quantity,
            unit: log.unit,
            imageUrl: log.imageUrl,
            loggedAt: log.loggedAt,
            food: {
                id: log.foodItemId,
                name: log.foodName,
            },
            nutrition: {
                calories: Math.round((log.cals_per_100g || 0) * factor),
                protein: Math.round((log.protein_per_100g || 0) * factor),
                carbs: Math.round((log.carbs_per_100g || 0) * factor),
                fats: Math.round((log.fats_per_100g || 0) * factor),
            },
        };
    });

    return enrichedLogs;
};

//! Created by Antigravity: Service to get daily nutrition summary (consumed vs target), including water and coach tip
export const getDailySummary = async (userId: string, dateStr: string) => {
    const logs = await getMealLogsByDate(userId, dateStr);

    // Sum up all consumed nutrition
    const consumed = logs.reduce(
        (acc, log) => {
            acc.calories += log.nutrition.calories;
            acc.protein += log.nutrition.protein;
            acc.carbs += log.nutrition.carbs;
            acc.fats += log.nutrition.fats;
            return acc;
        },
        { calories: 0, protein: 0, carbs: 0, fats: 0 }
    );

    // Get user targets
    const targets = await db.query.userTarget.findFirst({
        where: eq(userTarget.userId, userId)
    });

    const targetData = targets
        ? {
            calories: targets.calTotal,
            protein: targets.proteins,
            carbs: targets.carbs,
            fats: targets.fats,
        }
        : null;

    // Calculate remaining
    const remaining = targetData
        ? {
            calories: targetData.calories - consumed.calories,
            protein: targetData.protein - consumed.protein,
            carbs: targetData.carbs - consumed.carbs,
            fats: targetData.fats - consumed.fats,
        }
        : null;

    // Group logs by meal type
    const mealBreakdown: Record<string, typeof logs> = {};
    for (const log of logs) {
        if (!mealBreakdown[log.mealType]) {
            mealBreakdown[log.mealType] = [];
        }
        mealBreakdown[log.mealType].push(log);
    }

    // 1. Fetch water logs for the day
    const startOfDay = new Date(dateStr);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(dateStr);
    endOfDay.setHours(23, 59, 59, 999);

    const waterLogsToday = await db
        .select()
        .from(waterLogs)
        .where(
            and(
                eq(waterLogs.userId, userId),
                gte(waterLogs.loggedAt, startOfDay),
                lte(waterLogs.loggedAt, endOfDay)
            )
        );

    const waterConsumed = waterLogsToday.reduce((sum, log) => sum + (log.amount_ml || 0), 0);
    const waterTarget = targets?.water_ml ?? 2500; // default to 2500ml as shown in mockup

    // 2. Select coach tip of the day
    const COACH_TIPS = [
        "Eating protein at breakfast significantly reduces cravings later in the day. Keep crushing it! 🔥",
        "Stay hydrated! Drinking water before meals can help with digestion and portion control. 💧",
        "Fiber is your friend! Adding leafy greens or chia seeds helps stabilize blood sugar. 🥗",
        "Consistency is key. Small daily improvements lead to massive long-term results! 💪",
        "Get moving! A 10-minute walk after meals helps lower postprandial glucose levels. 🚶"
    ];
    const tipIndex = dateStr ? (dateStr.charCodeAt(dateStr.length - 1) % COACH_TIPS.length) : 0;
    const coachTip = COACH_TIPS[tipIndex];

    return {
        date: dateStr,
        consumed,
        target: targetData,
        remaining,
        waterConsumed,
        waterTarget,
        coachTip,
        totalMealsLogged: logs.length,
        mealBreakdown,
    };
};

//! Created by Antigravity: Service to log water intake
export const logWater = async (userId: string, amount_ml: number, dateStr?: string) => {
    if (amount_ml <= 0) {
        throw new BadRequest("Water amount must be greater than 0");
    }

    const logDate = dateStr ? new Date(dateStr) : new Date();

    const result = await db.insert(waterLogs).values({
        userId,
        amount_ml,
        loggedAt: logDate
    });

    return {
        message: "Water logged successfully",
        amount_ml,
        loggedAt: logDate
    };
};

//! Created by Antigravity: Service to get water logs for a specific date
export const getWaterLogsByDate = async (userId: string, dateStr: string) => {
    const startOfDay = new Date(dateStr);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(dateStr);
    endOfDay.setHours(23, 59, 59, 999);

    const logs = await db
        .select()
        .from(waterLogs)
        .where(
            and(
                eq(waterLogs.userId, userId),
                gte(waterLogs.loggedAt, startOfDay),
                lte(waterLogs.loggedAt, endOfDay)
            )
        );

    const totalConsumed = logs.reduce((sum, log) => sum + (log.amount_ml || 0), 0);

    return {
        date: dateStr,
        totalConsumed,
        logs
    };
};

//! Created by Antigravity: Service to get completion summary containing macro details and dynamic coach insights
export const getCompletionSummary = async (userId: string, dateStr: string) => {
    // 1. Fetch meal logs for the day
    const logs = await getMealLogsByDate(userId, dateStr);

    // Sum up consumed
    const consumed = logs.reduce(
        (acc, log) => {
            acc.calories += log.nutrition.calories;
            acc.protein += log.nutrition.protein;
            acc.carbs += log.nutrition.carbs;
            acc.fats += log.nutrition.fats;
            return acc;
        },
        { calories: 0, protein: 0, carbs: 0, fats: 0 }
    );

    // 2. Fetch targets
    const targets = await db.query.userTarget.findFirst({
        where: eq(userTarget.userId, userId)
    });

    const targetData = {
        calories: targets?.calTotal ?? 2000,
        protein: targets?.proteins ?? 150,
        carbs: targets?.carbs ?? 200,
        fats: targets?.fats ?? 67,
    };

    // Calculate remaining
    const remaining = {
        calories: Math.max(0, targetData.calories - consumed.calories),
        protein: Math.max(0, targetData.protein - consumed.protein),
        carbs: Math.max(0, targetData.carbs - consumed.carbs),
        fats: Math.max(0, targetData.fats - consumed.fats),
    };

    // 3. Check if already completed
    const existing = await db.query.completedDays.findFirst({
        where: and(
            eq(completedDays.userId, userId),
            eq(completedDays.completedDate, dateStr)
        )
    });

    const isCompleted = !!existing;

    // 4. Generate dynamic Coach Insight based on macro adherence
    let coachInsight = "Fantastic work tracking all meals today! Consistency is the single most important factor in reaching your health goals. Keep it up!";
    
    const proteinRatio = consumed.protein / targetData.protein;
    const caloriesRatio = consumed.calories / targetData.calories;
    const fatsRatio = consumed.fats / targetData.fats;

    if (proteinRatio >= 0.9 && proteinRatio <= 1.1) {
        coachInsight = "Great job staying on track! You hit your protein goal perfectly today. Tomorrow, try adding a few more healthy fats at lunch.";
    } else if (proteinRatio < 0.8) {
        coachInsight = "You logged a solid amount of meals, but your protein was slightly below target today. Tomorrow, try incorporating Greek yogurt or eggs into breakfast to kickstart your protein intake.";
    } else if (fatsRatio > 1.25) {
        coachInsight = "You had a great logging streak today, but your fat intake exceeded target. Try choosing leaner protein sources like turkey breast, fish, or tofu tomorrow.";
    } else if (caloriesRatio >= 0.9 && caloriesRatio <= 1.05) {
        coachInsight = "Excellent job! You kept your calories right on target today. Keep up this consistency for great long-term results.";
    }

    return {
        date: dateStr,
        isCompleted,
        consumed,
        target: targetData,
        remaining,
        coachInsight
    };
};

//! Created by Antigravity: Service to complete day logging and reward user with +100 XP
export const completeDay = async (userId: string, dateStr: string) => {
    // Check if already completed
    const existing = await db.query.completedDays.findFirst({
        where: and(
            eq(completedDays.userId, userId),
            eq(completedDays.completedDate, dateStr)
        )
    });

    if (existing) {
        return await getCompletionSummary(userId, dateStr);
    }

    // Insert completion record
    await db.insert(completedDays).values({
        userId,
        completedDate: dateStr
    });

    // Award +100 XP to the user
    const userObj = await db.query.users.findFirst({
        where: eq(users.id, userId)
    });

    if (userObj) {
        const currentXp = userObj.xp || 0;
        await db.update(users)
            .set({ xp: currentXp + 100 })
            .where(eq(users.id, userId));
    }

    return await getCompletionSummary(userId, dateStr);
};
