import { mysqlTable, varchar, timestamp } from 'drizzle-orm/mysql-core';
import { users } from './user';

//! Created by Antigravity: Table to track days when a user completed their logging targets
export const completedDays = mysqlTable('completed_days', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  userId: varchar('userId', { length: 36 }).references(() => users.id).notNull(),
  completedDate: varchar('completedDate', { length: 10 }).notNull(), // format: YYYY-MM-DD
  completedAt: timestamp('completedAt').defaultNow().notNull(),
});
