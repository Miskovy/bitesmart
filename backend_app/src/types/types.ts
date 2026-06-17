import { InferSelectModel } from "drizzle-orm";
import { users } from "../db/schema";

export type BaseUser = InferSelectModel<typeof users>;
