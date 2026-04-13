import { mysqlTable, varchar, boolean } from 'drizzle-orm/mysql-core';
import { users } from './user';

export const userMedicalConditions = mysqlTable('usermedicalconditions', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  userId: varchar('userId', { length: 36 })
    .notNull()
    .references(() => users.id),

  isDiabetesType1: boolean('isDiabetesType1'),
  isDiabetesType2: boolean('isDiabetesType2'),
  isHypertension: boolean('isHypertension'),
  isPCOS: boolean('isPCOS'),
  isAnemia: boolean('isAnemia'),

  isCeliacDisease: boolean('isCeliacDisease'),
  isIBS: boolean('isIBS'),
});