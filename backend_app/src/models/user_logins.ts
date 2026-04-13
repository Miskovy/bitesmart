import { mysqlTable, varchar, int, timestamp } from 'drizzle-orm/mysql-core'; 
import { users } from './user'; 
export const userLogins = mysqlTable('user_logins', { 
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()), 
  userId: varchar('userId', { length: 36 })
    .notNull()
    .references(() => users.id), 
  lastLogin: timestamp('lastLogin').notNull(), 
  streak: int('streak').notNull().default(0), 
});