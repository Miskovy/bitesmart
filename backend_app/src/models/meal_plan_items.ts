import { mysqlTable, varchar, int, date, boolean, mysqlEnum } from 'drizzle-orm/mysql-core';
import { mealPlans } from './meal_plans';
import { foodItems } from './food_items';
import { recipes } from './recipes';

export const mealTypeEnum = ['Breakfast', 'Lunch', 'Dinner', 'Snack'] as const;

export const mealPlanItems = mysqlTable('meal_plan_items', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  planId: varchar('planId', { length: 36 }).references(() => mealPlans.id),
  foodItemId: int('foodItemId').references(() => foodItems.id),
  recipeId: varchar('recipeId', { length: 36 }).references(() => recipes.id),
  scheduledDate: date('scheduledDate').notNull(),
  mealType: mysqlEnum('mealType', mealTypeEnum).notNull(),
  isConsumed: boolean('isConsumed').default(false),
});