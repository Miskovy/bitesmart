import { mysqlTable, varchar, int } from 'drizzle-orm/mysql-core';

export const badges = mysqlTable('badges', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  name: varchar('name', { length: 255 }).notNull(),
  description: varchar('description', { length: 255 }),
  iconUrl: varchar('iconUrl', { length: 255 }),
  requiredXp: int('requiredXp'),
});