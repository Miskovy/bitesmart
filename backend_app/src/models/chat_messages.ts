import { mysqlTable, varchar, text, timestamp } from 'drizzle-orm/mysql-core';
import { chatSessions } from './chat_sessions';

export const chatMessages = mysqlTable('chat_messages', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  sessionId: varchar('sessionId', { length: 36 }).notNull().references(() => chatSessions.id),
  role: varchar('role', { length: 255 }).notNull(),
  content: text('content').notNull(),
  createdAt: timestamp('createdAt').defaultNow(),
});