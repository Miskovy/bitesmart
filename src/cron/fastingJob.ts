import cron from "node-cron";
import { eq, and, desc } from "drizzle-orm";
import { db } from "../db/connection";
import { users } from "../models/user";
import { userDietaryPreferences } from "../models/user_dietary_preferences";
import { dailyLogs } from "../models/daily_logs";

// In-memory cache to prevent repeatedly notifying the user within the same fasting period.
const notifiedCache = new Set<string>();

export interface FastingCheckResult {
  checkedUsersCount: number;
  notifiedUsers: Array<{
    userId: string;
    name: string;
    elapsedHours: number;
    lastMealTime: Date;
  }>;
  skippedUsers: Array<{
    userId: string;
    name: string;
    reason: string;
    elapsedHours?: number;
    lastMealTime?: Date;
  }>;
}

/**
 * Runs the query joins, isolates GLP-1 users, calculates elapsed time since their last meal,
 * and sends mock push notifications if the 5-hour fasting window is exceeded.
 */
export const checkFastingThresholds = async (): Promise<FastingCheckResult> => {
  const result: FastingCheckResult = {
    checkedUsersCount: 0,
    notifiedUsers: [],
    skippedUsers: []
  };

  try {
    console.log("[Fasting Cron] Running fasting threshold checks...");

    // 1. Join users and userDietaryPreferences to isolate isGlp1User
    const glp1Users = await db
      .select({
        id: users.id,
        name: users.name,
        deviceToken: users.deviceToken,
        notificationsEnabled: users.notificationsEnabled,
        createdAt: users.createdAt
      })
      .from(users)
      .innerJoin(
        userDietaryPreferences,
        eq(users.id, userDietaryPreferences.userId)
      )
      .where(eq(userDietaryPreferences.isGlp1User, true));

    result.checkedUsersCount = glp1Users.length;

    for (const user of glp1Users) {
      try {
        // 2. Fetch the user's latest meal log
        const latestLogs = await db
          .select({
            loggedAt: dailyLogs.loggedAt
          })
          .from(dailyLogs)
          .where(eq(dailyLogs.userId, user.id))
          .orderBy(desc(dailyLogs.loggedAt))
          .limit(1);

        const lastMealTime =
          latestLogs.length > 0 && latestLogs[0].loggedAt
            ? new Date(latestLogs[0].loggedAt)
            : new Date(user.createdAt);

        // 3. Calculate elapsed time in hours
        const elapsedMs = Date.now() - lastMealTime.getTime();
        const elapsedHours = elapsedMs / (1000 * 60 * 60);

        // 4. Verify the 5-hour fasting threshold
        if (elapsedHours >= 5) {
          if (!user.notificationsEnabled) {
            result.skippedUsers.push({
              userId: user.id,
              name: user.name,
              reason: "Notifications are disabled by the user settings",
              elapsedHours,
              lastMealTime
            });
            console.log(
              `[Fasting Cron] User ${user.name} (${user.id}) exceeded fasting window (${elapsedHours.toFixed(1)}h), but notifications are disabled.`
            );
            continue;
          }

          if (!user.deviceToken) {
            result.skippedUsers.push({
              userId: user.id,
              name: user.name,
              reason: "User has no device registration token",
              elapsedHours,
              lastMealTime
            });
            console.log(
              `[Fasting Cron] User ${user.name} (${user.id}) exceeded fasting window (${elapsedHours.toFixed(1)}h), but has no deviceToken.`
            );
            continue;
          }

          // Check if we already notified the user for this specific fasting window
          const cacheKey = `${user.id}-${lastMealTime.getTime()}`;
          if (notifiedCache.has(cacheKey)) {
            result.skippedUsers.push({
              userId: user.id,
              name: user.name,
              reason: "Already notified for this fasting period",
              elapsedHours,
              lastMealTime
            });
            console.log(
              `[Fasting Cron] User ${user.name} (${user.id}) exceeded fasting window (${elapsedHours.toFixed(1)}h), but was already notified.`
            );
            continue;
          }

          // Send mock push notification (console log)
          console.log(
            `\n>>> [PUSH NOTIFICATION SENT] TO: ${user.name} (token: ${user.deviceToken})\n` +
            `>>> MESSAGE: You have been fasting for ${elapsedHours.toFixed(1)} hours. As a GLP-1 user, make sure to check in and have a balanced snack or meal to keep your energy stable!\n`
          );

          // Mark as notified in cache
          notifiedCache.add(cacheKey);

          result.notifiedUsers.push({
            userId: user.id,
            name: user.name,
            elapsedHours,
            lastMealTime
          });
        } else {
          result.skippedUsers.push({
            userId: user.id,
            name: user.name,
            reason: `Fasting window not exceeded yet (only ${elapsedHours.toFixed(1)}h since last meal)`,
            elapsedHours,
            lastMealTime
          });
        }
      } catch (userErr) {
        console.error(
          `[Fasting Cron] Error checking thresholds for user ${user.name} (${user.id}):`,
          userErr
        );
        result.skippedUsers.push({
          userId: user.id,
          name: user.name,
          reason: `Error during evaluation: ${String(userErr)}`
        });
      }
    }
  } catch (err) {
    console.error("[Fasting Cron] Error in fasting threshold check loop:", err);
  }

  return result;
};

/**
 * Initializes and schedules the fasting cron job.
 */
export const initFastingCron = () => {
  // Run checks immediately on startup
  checkFastingThresholds().catch(err =>
    console.error("[Fasting Cron] Initial startup run failed:", err)
  );

  // Schedule cron job to run at continuous 1-hour intervals (minute 0 of every hour)
  // Pattern: "0 * * * *"
  const cronPattern = process.env.FASTING_CRON_PATTERN || "0 * * * *";
  
  console.log(`[Fasting Cron] Cron job scheduled with pattern: "${cronPattern}"`);

  cron.schedule(cronPattern, () => {
    checkFastingThresholds().catch(err =>
      console.error("[Fasting Cron] Scheduled execution failed:", err)
    );
  });
};
