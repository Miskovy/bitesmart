import { mysqlTable, varchar, boolean, timestamp } from 'drizzle-orm/mysql-core';
import { dailyLogs } from './daily_logs';
import { users } from './user';

export const aiTrainingData = mysqlTable('ai_training_data', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  userId: varchar('userId', { length: 36 }).references(() => users.id),
  logId: varchar('logId', { length: 36 }).references(() => dailyLogs.id),
  originalPrediction: varchar('originalPrediction', { length: 255 }),
  userCorrection: varchar('userCorrection', { length: 255 }),
  imageSnapshot: varchar('imageSnapshot', { length: 255 }),
  isReviewedByAdmin: boolean('isReviewedByAdmin').default(false),
  createdAt: timestamp('createdAt').defaultNow().notNull(),
});