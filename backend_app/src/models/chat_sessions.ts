import { mysqlTable, varchar, timestamp } from 'drizzle-orm/mysql-core';
import { users } from './user';

export const chatSessions = mysqlTable('chat_sessions', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  userId: varchar('userId', { length: 36 }).notNull().references(() => users.id),
  title: varchar('title', { length: 255 }),
  createdAt: timestamp('createdAt').defaultNow(),
  updatedAt: timestamp('updatedAt').defaultNow().onUpdateNow(),
});