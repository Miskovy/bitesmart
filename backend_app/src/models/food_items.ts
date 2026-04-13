import { mysqlTable, int, varchar, double, boolean, mysqlEnum } from 'drizzle-orm/mysql-core';

export const foodSourceEnum = ['USDA', 'OpenFood', 'Local', 'UserCreated'] as const;

export const foodItems = mysqlTable('food_items', {
  id: int('id').primaryKey().autoincrement(),
  class_name: varchar('class_name', { length: 255 }).notNull().unique(),
  avg_height_cm: double('avg_height_cm').notNull().default(2.0),
  density_g_cm3: double('density_g_cm3').notNull().default(1.0),
  protein_per_100g: double('protein_per_100g').notNull().default(0.0),
  carbs_per_100g: double('carbs_per_100g').notNull().default(0.0),
  fats_per_100g: double('fats_per_100g').notNull().default(0.0),
  cals_per_100g: double('cals_per_100g').notNull().default(0.0),
  iron_mg: double('iron_mg'),
  sodium_mg: double('sodium_mg'),
  servingUnit: varchar('servingUnit', { length: 255 }),
  barcode: varchar('barcode', { length: 255 }).unique(),
  source: mysqlEnum('source', foodSourceEnum),
  isVerified: boolean('isVerified').default(false),
});