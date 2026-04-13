import { mysqlTable, varchar, timestamp } from 'drizzle-orm/mysql-core';
import { users } from './user';
import { badges } from './badges';

export const userBadges = mysqlTable('user_badges', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  userId: varchar('userId', { length: 36 }).references(() => users.id),
  badgeId: varchar('badgeId', { length: 36 }).references(() => badges.id),
  earnedAt: timestamp('earnedAt').defaultNow(),
});