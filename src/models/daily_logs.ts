import { mysqlTable, varchar, int, double, timestamp, mysqlEnum } from 'drizzle-orm/mysql-core';
import { users } from './user';
import { foodItems } from './food_items';

export const mealTypeEnum = ['Breakfast', 'Lunch', 'Dinner', 'Snack'] as const;

export const dailyLogs = mysqlTable('dailylogs', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  userId: varchar('userId', { length: 36 }).references(() => users.id),
  foodItemId: int('foodItemId').references(() => foodItems.id),
  mealType: mysqlEnum('mealType', mealTypeEnum).notNull(),
  quantity: double('quantity').notNull(),
  unit: varchar('unit', { length: 255 }).default('g'),
  imageUrl: varchar('imageUrl', { length: 255 }),
  loggedAt: timestamp('loggedAt').defaultNow(),
});