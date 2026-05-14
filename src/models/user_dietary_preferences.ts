import { mysqlTable, varchar, boolean, int } from 'drizzle-orm/mysql-core';
import { users } from './user'; // Adjust this import path as needed

export const userDietaryPreferences = mysqlTable('user_dietary_preferences', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  userId: varchar('userId', { length: 36 })
    .notNull()
    .references(() => users.id),

  isVegetarian: boolean('isVegetarian'),
  isVegan: boolean('isVegan'),
  isKeto: boolean('isKeto'),
  isPaleo: boolean('isPaleo'),
  isGlutenFree: boolean('isGlutenFree'),
  isHalal: boolean('isHalal'),
  isPescatarian: boolean('isPescatarian'),

  isGlp1User: boolean('isGlp1User'),
  isRamadanMode: boolean('isRamadanMode'),

  //! Created by Antigravity: GLP-1 specific settings
  highProteinGoal: boolean('highProteinGoal').default(false),
  hydrationReminderHours: int('hydrationReminderHours').default(2),

  //! Created by Antigravity: Ramadan specific settings
  suhoorTime: varchar('suhoorTime', { length: 10 }),
  iftarTime: varchar('iftarTime', { length: 10 }),
  hydrationFocus: boolean('hydrationFocus').default(false),
});