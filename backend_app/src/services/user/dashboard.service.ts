import { db } from "../../db/connection";
import { users } from "../../models/user";
import { dailyLogs } from "../../models/daily_logs";
import { foodItems } from "../../models/food_items";
import { recipes } from "../../models/recipes";
import { count, sql, gte } from "drizzle-orm";

/**
 * Service to fetch Admin Dashboard statistics and chart data.
 */
export const getAdminDashboardData = async () => {
    // 1. Total counts
    const totalUsersResult = await db.select({ value: count() }).from(users);
    const totalUsers = totalUsersResult[0]?.value || 0;

    const totalMealsResult = await db.select({ value: count() }).from(dailyLogs);
    const totalMealsLogged = totalMealsResult[0]?.value || 0;

    const totalFoodItemsResult = await db.select({ value: count() }).from(foodItems);
    const totalFoodItems = totalFoodItemsResult[0]?.value || 0;

    const totalRecipesResult = await db.select({ value: count() }).from(recipes);
    const totalRecipes = totalRecipesResult[0]?.value || 0;

    // 2. Users by role (for pie/doughnut chart)
    const usersByRole = await db
        .select({
            role: users.role,
            count: count(),
        })
        .from(users)
        .groupBy(users.role);

    // 3. Recent meals logged per day for the last 7 days (for line/bar chart)
    const recentLogs = await db
        .select({
            date: sql<string>`DATE(${dailyLogs.loggedAt})`,
            count: count(),
        })
        .from(dailyLogs)
        .where(gte(dailyLogs.loggedAt, sql`NOW() - INTERVAL 7 DAY`))
        .groupBy(sql`DATE(${dailyLogs.loggedAt})`)
        .orderBy(sql`DATE(${dailyLogs.loggedAt})`);

    // 4. Recent user registrations per day for the last 7 days
    const recentRegistrations = await db
        .select({
            date: sql<string>`DATE(${users.createdAt})`,
            count: count(),
        })
        .from(users)
        .where(gte(users.createdAt, sql`NOW() - INTERVAL 7 DAY`))
        .groupBy(sql`DATE(${users.createdAt})`)
        .orderBy(sql`DATE(${users.createdAt})`);

    return {
        statistics: {
            totalUsers,
            totalMealsLogged,
            totalFoodItems,
            totalRecipes,
        },
        charts: {
            usersByRole,
            recentLogs,
            recentRegistrations,
        },
    };
};
