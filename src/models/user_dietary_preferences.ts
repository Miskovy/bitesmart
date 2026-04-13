import { mysqlTable, varchar, boolean } from 'drizzle-orm/mysql-core';
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
});