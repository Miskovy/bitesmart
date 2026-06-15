import { db } from "../../db/connection";
import { dailyLogs } from "../../models/daily_logs";
import { foodItems } from "../../models/food_items";
import { weightLogs } from "../../models/weight_logs";
import { users } from "../../models/user";
import { eq, and, gte, lte } from "drizzle-orm";
import { getCalendarDateString } from "../../utils/date";
import { BadRequest } from "../../errors";

export enum Period {
  Weekly = "Weekly",
  Monthly = "Monthly",
}

/**
 * Service to fetch dietary and weight insights for a user.
 * 
 * @param userId - ID of the user.
 * @param period - Period of insights (Weekly = 7 days, Monthly = 30 days).
 * @param timezone - Client's timezone string.
 * @param offsetMinutes - Client's timezone offset in minutes.
 */
export const getInsights = async (
  userId: string,
  period: Period,
  timezone?: string,
  offsetMinutes?: number
) => {
  const daysCount = period === Period.Weekly ? 7 : 30;

  // 1. Generate local date strings for the period
  const currentDate = new Date();
  const dateStrings: string[] = [];
  for (let i = daysCount - 1; i >= 0; i--) {
    const d = new Date(currentDate.getTime() - i * 24 * 60 * 60 * 1000);
    dateStrings.push(getCalendarDateString(d, timezone, offsetMinutes));
  }

  const startDateStr = dateStrings[0];
  const endDateStr = dateStrings[dateStrings.length - 1];

  const startOfRange = new Date(startDateStr);
  startOfRange.setHours(0, 0, 0, 0);

  const endOfRange = new Date(endDateStr);
  endOfRange.setHours(23, 59, 59, 999);

  // 2. Fetch meal logs during the period
  const logs = await db
    .select({
      quantity: dailyLogs.quantity,
      loggedAt: dailyLogs.loggedAt,
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
        gte(dailyLogs.loggedAt, startOfRange),
        lte(dailyLogs.loggedAt, endOfRange)
      )
    );

  // Initialize summary map for every calendar date in the period
  const dailySummaryMap = new Map<
    string,
    { calories: number; carbs: number; protein: number; fats: number }
  >();
  for (const dateStr of dateStrings) {
    dailySummaryMap.set(dateStr, { calories: 0, carbs: 0, protein: 0, fats: 0 });
  }

  // Aggregate macros and calories per day
  for (const log of logs) {
    if (!log.loggedAt) continue;
    const logDateStr = getCalendarDateString(log.loggedAt, timezone, offsetMinutes);
    const dayData = dailySummaryMap.get(logDateStr);
    if (dayData) {
      const factor = (log.quantity || 0) / 100;
      dayData.calories += Math.round((log.cals_per_100g || 0) * factor);
      dayData.carbs += Math.round((log.carbs_per_100g || 0) * factor);
      dayData.protein += Math.round((log.protein_per_100g || 0) * factor);
      dayData.fats += Math.round((log.fats_per_100g || 0) * factor);
    }
  }

  // Calculate Average Calories
  let totalCalories = 0;
  for (const day of dailySummaryMap.values()) {
    totalCalories += day.calories;
  }
  const avgCalories = Math.round(totalCalories / daysCount);

  // Build daily breakdown payload
  const periodData = dateStrings.map((dateStr) => {
    const dayData = dailySummaryMap.get(dateStr)!;
    return {
      date: dateStr,
      ...dayData,
    };
  });

  // Extract today's breakdown (the last date in the generated list)
  const todayStr = dateStrings[dateStrings.length - 1];
  const todaySummary = dailySummaryMap.get(todayStr) || { calories: 0, carbs: 0, protein: 0, fats: 0 };
  const todayBreakdown = {
    carbohydrates: todaySummary.carbs,
    protein: todaySummary.protein,
    fats: todaySummary.fats,
  };

  // 3. Weight log calculation
  // Fetch user default/current weight in case weight history is sparse
  const user = await db.query.users.findFirst({
    where: eq(users.id, userId),
    columns: { weight: true },
  });
  const defaultWeight = user?.weight || 0;

  // Fetch all weight logs for the user, ordered by date ascending
  const weightLogsList = await db
    .select()
    .from(weightLogs)
    .where(eq(weightLogs.userId, userId))
    .orderBy(weightLogs.loggedAt);

  // Construct continuous weight trend graph over the period (carry-forward interpolation)
  const weightGraph = dateStrings.map((dateStr) => {
    let activeWeight = defaultWeight;
    let found = false;

    // Search backwards for the most recent log on or before dateStr
    for (let i = weightLogsList.length - 1; i >= 0; i--) {
      const logDateStr = getCalendarDateString(
        weightLogsList[i].loggedAt,
        timezone,
        offsetMinutes
      );
      if (logDateStr <= dateStr) {
        activeWeight = weightLogsList[i].weight;
        found = true;
        break;
      }
    }

    // If no log exists before this date, but logs exist in the future, backfill with the first log
    if (!found && weightLogsList.length > 0) {
      activeWeight = weightLogsList[0].weight;
    }

    return {
      date: dateStr,
      weight: activeWeight,
    };
  });

  // Calculate overall weight change over the period
  let weightChange = 0;
  if (weightGraph.length > 0) {
    const startWeight = weightGraph[0].weight;
    const endWeight = weightGraph[weightGraph.length - 1].weight;
    weightChange = Math.round((endWeight - startWeight) * 10) / 10;
  }

  return {
    avgCalories,
    weightChange,
    weightGraph,
    periodData,
    todayBreakdown,
  };
};
