import { mysqlTable, varchar, double, int } from 'drizzle-orm/mysql-core';
import { recipes } from './recipes';
import { foodItems } from './food_items';

export const recipeIngredients = mysqlTable('recipe_ingredients', {
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  recipeId: varchar('recipeId', { length: 36 }).references(() => recipes.id),
  foodItemId: int('foodItemId').references(() => foodItems.id),
  quantity: double('quantity').notNull(),
  unit: varchar('unit', { length: 255 }).notNull(),
});