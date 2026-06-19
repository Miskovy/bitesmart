import { db } from "../../db/connection";
import { users } from "../../models/user";
import { dailyLogs } from "../../models/daily_logs";
import { foodItems } from "../../models/food_items";
import { waterLogs } from "../../models/water_logs";
import { userTarget } from "../../models/user_target";
import { eq, and, gte, lte } from "drizzle-orm";
import { getCalendarDateString } from "../../utils/date";
import { updateLoginStreak } from "./streak.service";
import { getInsights, Period } from "./insights.service";
import { NotFound } from "../../errors";

/**
 * Service to fetch comprehensive Home Dashboard data with insights, targets, and logs.
 * 
 * @param userId - ID of the user.
 * @param timezone - Client's timezone string.
 * @param offsetMinutes - Client's timezone offset in minutes.
 */
export const getUserDashboardData = async (
    userId: string,
    timezone?: string,
    offsetMinutes?: number
) => {
    // 1. Fetch user profile overview
    const user = await db.query.users.findFirst({
        where: eq(users.id, userId),
        columns: {
            id: true,
            name: true,
            email: true,
            xp: true,
            weight: true,
            role: true,
        },
    });

    if (!user) {
        throw new NotFound("User not found");
    }

    // 2. Fetch or update Login Streak
    const streak = await updateLoginStreak(userId, timezone, offsetMinutes);

    // 3. Fetch User Targets (or fall back to defaults)
    const targets = await db.query.userTarget.findFirst({
        where: eq(userTarget.userId, userId),
    });

    const dailyTargets = {
        calories: targets?.calTotal ?? 2000,
        protein: targets?.proteins ?? 150,
        carbs: targets?.carbs ?? 200,
        fats: targets?.fats ?? 67,
        water: targets?.water_ml ?? 2000,
    };

    // 4. Generate local range for "today"
    const todayStr = getCalendarDateString(new Date(), timezone, offsetMinutes);
    const startOfToday = new Date(todayStr);
    startOfToday.setHours(0, 0, 0, 0);

    const endOfToday = new Date(todayStr);
    endOfToday.setHours(23, 59, 59, 999);

    // 5. Fetch Today's Daily Meal Logs
    const todayMealLogs = await db
        .select({
            id: dailyLogs.id,
            mealType: dailyLogs.mealType,
            quantity: dailyLogs.quantity,
            unit: dailyLogs.unit,
            imageUrl: dailyLogs.imageUrl,
            loggedAt: dailyLogs.loggedAt,
            foodItemId: dailyLogs.foodItemId,
            class_name: foodItems.class_name,
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
                gte(dailyLogs.loggedAt, startOfToday),
                lte(dailyLogs.loggedAt, endOfToday)
            )
        );

    // 6. Aggregate Today's Macros
    let caloriesConsumed = 0;
    let proteinConsumed = 0;
    let carbsConsumed = 0;
    let fatsConsumed = 0;

    const meals = todayMealLogs.map((log) => {
        const factor = (log.quantity || 0) / 100;
        const calories = Math.round((log.cals_per_100g || 0) * factor);
        const protein = Math.round((log.protein_per_100g || 0) * factor);
        const carbs = Math.round((log.carbs_per_100g || 0) * factor);
        const fats = Math.round((log.fats_per_100g || 0) * factor);

        caloriesConsumed += calories;
        proteinConsumed += protein;
        carbsConsumed += carbs;
        fatsConsumed += fats;

        return {
            id: log.id,
            foodItemId: log.foodItemId,
            name: log.class_name || "Unknown Food",
            mealType: log.mealType,
            quantity: log.quantity,
            unit: log.unit || "g",
            imageUrl: log.imageUrl,
            loggedAt: log.loggedAt,
            macros: {
                calories,
                protein,
                carbs,
                fats,
            },
        };
    });

    // 7. Fetch Today's Water Consumption
    const todayWaterLogs = await db
        .select({ amount: waterLogs.amount_ml })
        .from(waterLogs)
        .where(
            and(
                eq(waterLogs.userId, userId),
                gte(waterLogs.loggedAt, startOfToday),
                lte(waterLogs.loggedAt, endOfToday)
            )
        );

    const waterConsumed = todayWaterLogs.reduce((sum, log) => sum + (log.amount || 0), 0);

    // 8. Fetch Weekly Trends from Insights
    const weeklyInsights = await getInsights(userId, Period.Weekly, timezone, offsetMinutes);

    // 9. Generate Smart Dynamic Textual Insights
    const insightsMessages: Array<{ type: string; title: string; message: string }> = [];

    // Calorie insight
    if (caloriesConsumed === 0) {
        insightsMessages.push({
            type: "calories",
            title: "Start Tracking",
            message: "You haven't logged any meals today. Let's start tracking your foods!",
        });
    } else if (caloriesConsumed > dailyTargets.calories) {
        insightsMessages.push({
            type: "calories",
            title: "Calorie Budget Exceeded",
            message: `You exceeded your daily calorie target by ${caloriesConsumed - dailyTargets.calories} kcal. Try choosing lower-calorie foods for the rest of the day.`,
        });
    } else if (caloriesConsumed >= dailyTargets.calories * 0.9) {
        insightsMessages.push({
            type: "calories",
            title: "On Track",
            message: "Excellent job! You are very close to hitting your daily calorie target.",
        });
    } else {
        insightsMessages.push({
            type: "calories",
            title: "Calories Remaining",
            message: `You have ${dailyTargets.calories - caloriesConsumed} kcal remaining to achieve your daily target.`,
        });
    }

    // Water insight
    if (waterConsumed === 0) {
        insightsMessages.push({
            type: "water",
            title: "Stay Hydrated",
            message: "Remember to drink and log your water intake today to maintain optimal hydration.",
        });
    } else if (waterConsumed < dailyTargets.water) {
        insightsMessages.push({
            type: "water",
            title: "Drink More Water",
            message: `You need ${dailyTargets.water - waterConsumed} ml more water to achieve your daily goal. Keep a bottle nearby!`,
        });
    } else {
        insightsMessages.push({
            type: "water",
            title: "Hydration Met",
            message: "Great job! You have fully achieved your daily hydration target.",
        });
    }

    // Weight insight
    if (weeklyInsights.weightChange < 0) {
        insightsMessages.push({
            type: "weight",
            title: "Weight Trend",
            message: `You have lost ${Math.abs(weeklyInsights.weightChange)} kg this week. Keep up the amazing work!`,
        });
    } else if (weeklyInsights.weightChange > 0) {
        insightsMessages.push({
            type: "weight",
            title: "Weight Trend",
            message: `You gained ${weeklyInsights.weightChange} kg this week. Consistency is key, stick to your daily targets!`,
        });
    }

    return {
        profile: {
            id: user.id,
            name: user.name,
            role: user.role,
            xp: user.xp,
            currentWeight: user.weight,
            streak,
        },
        targets: dailyTargets,
        progress: {
            calories: {
                consumed: caloriesConsumed,
                target: dailyTargets.calories,
                percentage: Math.round((caloriesConsumed / dailyTargets.calories) * 100),
            },
            protein: {
                consumed: proteinConsumed,
                target: dailyTargets.protein,
                percentage: Math.round((proteinConsumed / dailyTargets.protein) * 100),
            },
            carbs: {
                consumed: carbsConsumed,
                target: dailyTargets.carbs,
                percentage: Math.round((carbsConsumed / dailyTargets.carbs) * 100),
            },
            fats: {
                consumed: fatsConsumed,
                target: dailyTargets.fats,
                percentage: Math.round((fatsConsumed / dailyTargets.fats) * 100),
            },
            water: {
                consumed: waterConsumed,
                target: dailyTargets.water,
                percentage: Math.round((waterConsumed / dailyTargets.water) * 100),
            },
        },
        weeklyTrends: {
            avgCalories: weeklyInsights.avgCalories,
            weightChange: weeklyInsights.weightChange,
        },
        insights: insightsMessages,
        todayMeals: meals,
    };
};
