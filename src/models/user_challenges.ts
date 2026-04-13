import { mysqlTable, varchar, double, primaryKey } from 'drizzle-orm/mysql-core';
import { users } from './user';
import { communityChallenges } from './community_challenges';

export const userChallenges = mysqlTable('user_challenges', {
  userId: varchar('userId', { length: 36 }).notNull().references(() => users.id),
  challengeId: varchar('challengeId', { length: 36 }).notNull().references(() => communityChallenges.id),
  progress: double('progress'),
  status: varchar('status', { length: 255 }),
}, (table: any) => {
  return {
    pk: primaryKey({ columns: [table.userId, table.challengeId] }),
  };
});