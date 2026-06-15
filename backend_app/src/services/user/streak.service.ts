import { eq } from "drizzle-orm";
import { db } from "../../db/connection";
import { userLogins } from "../../models/user_logins";
import { getCalendarDateString } from "../../utils/date";

/**
 * Updates or initializes the user's login streak.
 * 
 * @param userId - The ID of the user.
 * @param timezone - Optional IANA timezone name (e.g. "Africa/Cairo").
 * @param offsetMinutes - Optional timezone offset in minutes.
 * @returns The updated streak count.
 */
export const updateLoginStreak = async (
  userId: string,
  timezone?: string,
  offsetMinutes?: number
): Promise<number> => {
  const currentDate = new Date();

  // Find the user's login record
  const loginRecord = await db.query.userLogins.findFirst({
    where: eq(userLogins.userId, userId),
  });

  if (!loginRecord) {
    // Initialize streak to 1
    await db.insert(userLogins).values({
      userId,
      lastLogin: currentDate,
      streak: 1,
    });
    return 1;
  }

  // Compare dates using timezone settings
  const lastLoginStr = getCalendarDateString(loginRecord.lastLogin, timezone, offsetMinutes);
  const currentStr = getCalendarDateString(currentDate, timezone, offsetMinutes);

  const lastLoginDay = new Date(lastLoginStr);
  const currentDay = new Date(currentStr);

  const diffTime = currentDay.getTime() - lastLoginDay.getTime();
  const diffDays = Math.round(diffTime / (1000 * 60 * 60 * 24));

  if (diffDays === 0) {
    // Same day: keep current streak but update the exact last login timestamp
    await db.update(userLogins)
      .set({ lastLogin: currentDate })
      .where(eq(userLogins.id, loginRecord.id));
    return loginRecord.streak;
  } else if (diffDays === 1) {
    // Consecutive day: increment streak
    const newStreak = loginRecord.streak + 1;
    await db.update(userLogins)
      .set({
        lastLogin: currentDate,
        streak: newStreak,
      })
      .where(eq(userLogins.id, loginRecord.id));
    return newStreak;
  } else {
    // Gap day or clock issue: reset streak to 1
    await db.update(userLogins)
      .set({
        lastLogin: currentDate,
        streak: 1,
      })
      .where(eq(userLogins.id, loginRecord.id));
    return 1;
  }
};
