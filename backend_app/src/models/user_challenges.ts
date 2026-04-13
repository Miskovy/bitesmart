import { mysqlTable, varchar, double, primaryKey, mysqlEnum } from 'drizzle-orm/mysql-core';
import { users } from './user';
import { communityChallenges } from './community_challenges';

export const statusUserChallengeEnum = mysqlEnum('status', ['Joined', 'Completed']);

export const userChallenges = mysqlTable('user_challenges', {
  userId: varchar('userId', { length: 36 }).notNull().references(() => users.id),
  challengeId: varchar('challengeId', { length: 36 }).notNull().references(() => communityChallenges.id),
  progress: double('progress'),
  status: statusUserChallengeEnum.notNull().default('Joined'),
}, (table) => {
  return {
    pk: primaryKey({ columns: [table.userId, table.challengeId] }),
  };
});