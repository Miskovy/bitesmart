import { mysqlTable, varchar, double, timestamp } from "drizzle-orm/mysql-core";
import { users } from "./user";

export const weightLogs = mysqlTable("weight_logs", {
  id: varchar("id", { length: 36 }).primaryKey().$defaultFn(() => crypto.randomUUID()),
  userId: varchar("userId", { length: 36 })
    .notNull()
    .references(() => users.id),
  weight: double("weight").notNull(),
  loggedAt: timestamp("loggedAt").defaultNow().notNull(),
});
