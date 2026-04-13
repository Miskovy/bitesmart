import { mysqlTable, varchar, int, timestamp } from 'drizzle-orm/mysql-core';
import { users } from './user';

export const waterLogs = mysqlTable('water_logs', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  userId: varchar('userId', { length: 36 }).references(() => users.id),
  amount_ml: int('amount_ml').notNull(),
  loggedAt: timestamp('loggedAt').defaultNow(),
});