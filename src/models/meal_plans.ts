import { mysqlTable, varchar, date, boolean } from 'drizzle-orm/mysql-core';
import { users } from './user';

export const mealPlans = mysqlTable('meal_plans', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  userId: varchar('userId', { length: 36 }).references(() => users.id),
  name: varchar('name', { length: 255 }),
  startDate: date('startDate'),
  endDate: date('endDate'),
  status: varchar('status', { length: 255 }),
  generatedByAI: boolean('generatedByAI').default(false),
});