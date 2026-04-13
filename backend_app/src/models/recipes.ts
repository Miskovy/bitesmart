import { mysqlTable, varchar, text, int, boolean, double } from 'drizzle-orm/mysql-core';
import { users } from './user';

export const recipes = mysqlTable('recipes', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  authorId: varchar('authorId', { length: 36 }).references(() => users.id),
  name: varchar('name', { length: 255 }).notNull(),
  description: text('description'),
  instructions: text('instructions'),
  prepTimeMinutes: int('prepTimeMinutes'),
  cookTimeMinutes: int('cookTimeMinutes'),
  isPublic: boolean('isPublic').default(false),
  totalCalories: int('totalCalories'),
  totalProtein: double('totalProtein'),
});