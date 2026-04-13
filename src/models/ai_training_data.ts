import { mysqlTable, varchar, boolean } from 'drizzle-orm/mysql-core';
import { dailyLogs } from './daily_logs';

export const aiTrainingData = mysqlTable('ai_training_data', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  logId: varchar('logId', { length: 36 }).references(() => dailyLogs.id),
  originalPrediction: varchar('originalPrediction', { length: 255 }),
  userCorrection: varchar('userCorrection', { length: 255 }),
  imageSnapshot: varchar('imageSnapshot', { length: 255 }),
  isReviewedByAdmin: boolean('isReviewedByAdmin').default(false),
});