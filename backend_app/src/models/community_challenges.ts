import { mysqlTable, varchar, text, timestamp, int } from 'drizzle-orm/mysql-core';

export const communityChallenges = mysqlTable('community_challenges', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  title: varchar('title', { length: 255 }),
  description: text('description'),
  startDate: timestamp('startDate'),
  endDate: timestamp('endDate'),
  participantsCount: int('participantsCount').default(0),
});