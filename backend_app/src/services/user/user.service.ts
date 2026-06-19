import { db } from "../../db/connection";
import { users } from "../../models/user";
import { weightLogs } from "../../models/weight_logs";
import { waterLogs } from "../../models/water_logs";
import { userTarget } from "../../models/user_target";
import { userSubscriptions } from "../../models/user_subscriptions";
import { userMedicalConditions } from "../../models/user_medical_conditions";
import { userLogins } from "../../models/user_logins";
import { userDietaryPreferences } from "../../models/user_dietary_preferences";
import { userChallenges } from "../../models/user_challenges";
import { userBadges } from "../../models/user_badges";
import { symptomLogs } from "../../models/symptom_logs";
import { shoppingList } from "../../models/shopping_list";
import { healthSync } from "../../models/health_sync";
import { dailyLogs } from "../../models/daily_logs";
import { completedDays } from "../../models/completed_days";
import { aiTrainingData } from "../../models/ai_training_data";
import { chatSessions } from "../../models/chat_sessions";
import { chatMessages } from "../../models/chat_messages";
import { mealPlans } from "../../models/meal_plans";
import { mealPlanItems } from "../../models/meal_plan_items";
import { recipes } from "../../models/recipes";
import { recipeIngredients } from "../../models/recipe_ingredients";

import { eq, or, like, desc, count, inArray } from "drizzle-orm";
import { NotFound, BadRequest } from "../../errors";
import bcrypt from "bcrypt";

/**
 * Get all users with pagination and search (name/email) filtering.
 * Excludes passwords from the returned objects.
 */
export const getAllUsers = async ({
  page = 1,
  pageSize = 10,
  query,
}: {
  page?: number;
  pageSize?: number;
  query?: string;
}) => {
  const skip = (page - 1) * pageSize;

  const whereClause = query
    ? or(like(users.name, `%${query}%`), like(users.email, `%${query}%`))
    : undefined;

  const totalResult = await db
    .select({ value: count() })
    .from(users)
    .where(whereClause);

  const total = totalResult[0]?.value || 0;

  const usersList = await db.query.users.findMany({
    where: whereClause,
    limit: pageSize,
    offset: skip,
    orderBy: [desc(users.createdAt)],
  });

  const safeUsers = usersList.map(({ password, ...rest }) => rest);

  return {
    users: safeUsers,
    total,
    page,
    pageSize,
  };
};

/**
 * Get a single user by ID. Excludes password.
 */
export const getUserById = async (userId: string) => {
  const user = await db.query.users.findFirst({
    where: eq(users.id, userId),
  });

  if (!user) {
    throw new NotFound(`User with ID ${userId} not found`);
  }

  const { password, ...safeUser } = user;
  return safeUser;
};

/**
 * Create a new user (intended for admin/manager control).
 */
export const createUser = async (data: any) => {
  const { email, password, name, role, age, ...extraData } = data;

  if (!email || !password || !name) {
    throw new BadRequest("Email, password, and name are required");
  }

  // Check uniqueness of email
  const existing = await db.query.users.findFirst({
    where: eq(users.email, email),
  });

  if (existing) {
    throw new BadRequest("Email already exists");
  }

  const hashedPassword = await bcrypt.hash(password, 10);
  const userId = crypto.randomUUID();

  await db.insert(users).values({
    id: userId,
    email,
    password: hashedPassword,
    name,
    role: role || "User",
    age: age !== undefined ? age : 0,
    ...extraData,
  });

  const createdUser = await db.query.users.findFirst({
    where: eq(users.id, userId),
  });

  if (!createdUser) {
    throw new BadRequest("Failed to retrieve created user");
  }

  const { password: _pw, ...safeUser } = createdUser;
  return safeUser;
};

/**
 * Update an existing user.
 */
export const updateUser = async (userId: string, data: any) => {
  const user = await db.query.users.findFirst({
    where: eq(users.id, userId),
  });

  if (!user) {
    throw new NotFound(`User with ID ${userId} not found`);
  }

  const { email, password, ...updateData } = data;
  const updates: any = { ...updateData };

  if (email && email !== user.email) {
    const existing = await db.query.users.findFirst({
      where: eq(users.email, email),
    });

    if (existing) {
      throw new BadRequest("Email is already taken");
    }
    updates.email = email;
  }

  if (password) {
    updates.password = await bcrypt.hash(password, 10);
  }

  if (Object.keys(updates).length > 0) {
    await db.update(users).set(updates).where(eq(users.id, userId));
  }

  const updatedUser = await db.query.users.findFirst({
    where: eq(users.id, userId),
  });

  if (!updatedUser) {
    throw new BadRequest("Failed to retrieve updated user");
  }

  const { password: _pw, ...safeUser } = updatedUser;
  return safeUser;
};

/**
 * Delete a user and cascade deletion of all user records across all models.
 */
export const deleteUser = async (userId: string) => {
  const user = await db.query.users.findFirst({
    where: eq(users.id, userId),
  });

  if (!user) {
    throw new NotFound(`User with ID ${userId} not found`);
  }

  await db.transaction(async (tx) => {
    // 1. Delete chatMessages by user's chatSessions
    const userSessionIds = (
      await tx
        .select({ id: chatSessions.id })
        .from(chatSessions)
        .where(eq(chatSessions.userId, userId))
    ).map((s) => s.id);

    if (userSessionIds.length > 0) {
      await tx
        .delete(chatMessages)
        .where(inArray(chatMessages.sessionId, userSessionIds));
    }

    // 2. Delete mealPlanItems by user's mealPlans
    const userMealPlanIds = (
      await tx
        .select({ id: mealPlans.id })
        .from(mealPlans)
        .where(eq(mealPlans.userId, userId))
    ).map((p) => p.id);

    if (userMealPlanIds.length > 0) {
      await tx
        .delete(mealPlanItems)
        .where(inArray(mealPlanItems.planId, userMealPlanIds));
    }

    // 3. Delete recipeIngredients by user's recipes
    const userRecipeIds = (
      await tx
        .select({ id: recipes.id })
        .from(recipes)
        .where(eq(recipes.authorId, userId))
    ).map((r) => r.id);

    if (userRecipeIds.length > 0) {
      await tx
        .delete(recipeIngredients)
        .where(inArray(recipeIngredients.recipeId, userRecipeIds));
    }

    // 4. Delete recipes authored by user
    await tx.delete(recipes).where(eq(recipes.authorId, userId));

    // 5. Delete mealPlans owned by user
    await tx.delete(mealPlans).where(eq(mealPlans.userId, userId));

    // 6. Delete chatSessions owned by user
    await tx.delete(chatSessions).where(eq(chatSessions.userId, userId));

    // 7. Delete weightLogs
    await tx.delete(weightLogs).where(eq(weightLogs.userId, userId));

    // 8. Delete waterLogs
    await tx.delete(waterLogs).where(eq(waterLogs.userId, userId));

    // 9. Delete userTarget
    await tx.delete(userTarget).where(eq(userTarget.userId, userId));

    // 10. Delete userSubscriptions
    await tx.delete(userSubscriptions).where(eq(userSubscriptions.userId, userId));

    // 11. Delete userMedicalConditions
    await tx.delete(userMedicalConditions).where(eq(userMedicalConditions.userId, userId));

    // 12. Delete userLogins
    await tx.delete(userLogins).where(eq(userLogins.userId, userId));

    // 13. Delete userDietaryPreferences
    await tx.delete(userDietaryPreferences).where(eq(userDietaryPreferences.userId, userId));

    // 14. Delete userChallenges
    await tx.delete(userChallenges).where(eq(userChallenges.userId, userId));

    // 15. Delete userBadges
    await tx.delete(userBadges).where(eq(userBadges.userId, userId));

    // 16. Delete symptomLogs
    await tx.delete(symptomLogs).where(eq(symptomLogs.userId, userId));

    // 17. Delete shoppingList
    await tx.delete(shoppingList).where(eq(shoppingList.userId, userId));

    // 18. Delete healthSync
    await tx.delete(healthSync).where(eq(healthSync.userId, userId));

    // 19. Delete dailyLogs
    await tx.delete(dailyLogs).where(eq(dailyLogs.userId, userId));

    // 20. Delete completedDays
    await tx.delete(completedDays).where(eq(completedDays.userId, userId));

    // 21. Delete aiTrainingData
    await tx.delete(aiTrainingData).where(eq(aiTrainingData.userId, userId));

    // 22. Delete the user
    await tx.delete(users).where(eq(users.id, userId));
  });

  return { id: userId, message: "User and all related records deleted successfully" };
};