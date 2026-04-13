import { mysqlTable, varchar, int, double, boolean } from 'drizzle-orm/mysql-core';
import { users } from './user';
import { foodItems } from './food_items';

export const shoppingList = mysqlTable('shopping_list', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  userId: varchar('userId', { length: 36 }).references(() => users.id),
  foodItemId: int('foodItemId').references(() => foodItems.id),
  quantity: double('quantity'),
  unit: varchar('unit', { length: 255 }),
  isPurchased: boolean('isPurchased').default(false),
  talabatLink: varchar('talabatLink', { length: 255 }),
});