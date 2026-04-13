import { mysqlTable, varchar, int, text } from 'drizzle-orm/mysql-core';

export const plans = mysqlTable('plans', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  name: varchar('name', { length: 255 }).notNull(),
  monthlyPrice: int('monthlyPrice').notNull(),
  yearlyPrice: int('yearlyPrice').notNull(),
  features: text('features'),
});