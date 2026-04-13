import { mysqlTable, varchar, timestamp } from 'drizzle-orm/mysql-core';
import { users } from './user';
import { plans } from './plans';

export const userSubscriptions = mysqlTable('user_subscriptions', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  userId: varchar('userId', { length: 36 }).references(() => users.id),
  planId: varchar('planId', { length: 36 }).references(() => plans.id),
  status: varchar('status', { length: 255 }),
  startDate: timestamp('startDate'),
  endDate: timestamp('endDate'),
});