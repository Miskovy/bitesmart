import { mysqlTable, varchar, int, timestamp, date } from 'drizzle-orm/mysql-core';
import { users } from './user';

export const healthSync = mysqlTable('health_sync', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  userId: varchar('userId', { length: 36 }).notNull().references(() => users.id),
  activeCaloriesBurned: int('activeCaloriesBurned').default(0),
  steps: int('steps').default(0),
  syncDate: date('syncDate').notNull(),
  updatedAt: timestamp('updatedAt').defaultNow().onUpdateNow(),
});
