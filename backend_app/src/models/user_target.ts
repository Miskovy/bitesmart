import { mysqlTable, varchar, int, double } from 'drizzle-orm/mysql-core';
import { users } from './user';

export const userTarget = mysqlTable('usertarget', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  userId: varchar('userId', { length: 36 }).notNull().references(() => users.id),
  calTotal: int('calTotal').notNull(),
  proteins: int('proteins').notNull(),
  carbs: int('carbs').notNull(),
  fats: int('fats').notNull(),
  iron_mg: double('iron_mg'),
  sodium_mg: double('sodium_mg'),
  vitamin_d_iu: double('vitamin_d_iu'),
  water_ml: int('water_ml').default(2000),
});