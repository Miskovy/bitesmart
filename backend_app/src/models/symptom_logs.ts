import { mysqlTable, varchar, int, text, timestamp } from 'drizzle-orm/mysql-core';
import { users } from './user';

export const symptomLogs = mysqlTable('symptom_logs', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  userId: varchar('userId', { length: 36 }).references(() => users.id),
  symptom: varchar('symptom', { length: 255 }).notNull(),
  severity: int('severity'),
  notes: text('notes'),
  loggedAt: timestamp('loggedAt').defaultNow(),
});