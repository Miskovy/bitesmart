import { eq, and, gte, lte, sql } from "drizzle-orm";
import { db } from "../../db/connection";
import { dailyLogs } from "../../models/daily_logs";
import { foodItems } from "../../models/food_items";
import { userTarget } from "../../models/user_target";
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

//! Created by Antigravity: Service to get daily nutrition summary (consumed vs target)
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

    return {
        date: dateStr,
        consumed,
        target: targetData,
        remaining,
        totalMealsLogged: logs.length,
        mealBreakdown,
    };
};
