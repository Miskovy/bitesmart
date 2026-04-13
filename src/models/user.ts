import { mysqlTable, varchar, double, int, timestamp, mysqlEnum } from 'drizzle-orm/mysql-core';  

export const goalsEnum = ['WeightLoss', 'Maintenance', 'MuscleGain'] as const;  
export const userRoleEnum = ['User', 'Admin', 'ContentManager'] as const;  
export const activityLevelEnum = ['Sedentary', 'LightlyActive', 'ModeratelyActive', 'VeryActive'] as const;  
export const gendersEnum = ['Male', 'Female'] as const;  

export const users = mysqlTable('users', {  
  id: varchar('id', { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),  
  name: varchar('name', { length: 255 }).notNull(),  
  password: varchar('password', { length: 255 }).notNull(),  
  email: varchar('email', { length: 255 }).notNull().unique(),  
  googleId: varchar('googleId', { length: 255 }),  
  avatar: varchar('avatar', { length: 255 }),  
  role: mysqlEnum('role', userRoleEnum).notNull().default('User'),  
  height: double('height'),  
  weight: double('weight'),  
  bmi: double('BMI'),  
  gender: mysqlEnum('gender', gendersEnum),  
  age: int('age').notNull(),  
  activityLevel: mysqlEnum('activityLevel', activityLevelEnum),  
  xp: int('xp').notNull().default(0),  
  userGoal: mysqlEnum('userGoal', goalsEnum),  
  createdAt: timestamp('created_at').defaultNow().notNull(),  
});  
