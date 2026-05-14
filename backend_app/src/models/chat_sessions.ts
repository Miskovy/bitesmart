import { mysqlTable, varchar, timestamp, mysqlEnum } from 'drizzle-orm/mysql-core';
import { users } from './user';

//! Created by Antigravity: Added category enum for chat session tagging
export const chatCategoryEnum = ['Advice', 'Nutrition', 'General'] as const;

export const chatSessions = mysqlTable('chat_sessions', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  userId: varchar('userId', { length: 36 }).notNull().references(() => users.id),
  title: varchar('title', { length: 255 }),
  //! Created by Antigravity: Category tag for chat history filtering
  category: mysqlEnum('category', chatCategoryEnum).default('General'),
  createdAt: timestamp('createdAt').defaultNow(),
  updatedAt: timestamp('updatedAt').defaultNow().onUpdateNow(),
});