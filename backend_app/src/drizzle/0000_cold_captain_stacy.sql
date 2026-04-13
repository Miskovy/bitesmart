CREATE TABLE `ai_training_data` (
	`id` varchar(36) NOT NULL,
	`logId` varchar(36),
	`originalPrediction` varchar(255),
	`userCorrection` varchar(255),
	`imageSnapshot` varchar(255),
	`isReviewedByAdmin` boolean DEFAULT false,
	CONSTRAINT `ai_training_data_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `badges` (
	`id` varchar(36) NOT NULL,
	`name` varchar(255) NOT NULL,
	`description` varchar(255),
	`iconUrl` varchar(255),
	`requiredXp` int,
	CONSTRAINT `badges_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `chat_messages` (
	`id` varchar(36) NOT NULL,
	`sessionId` varchar(36) NOT NULL,
	`role` varchar(255) NOT NULL,
	`content` text NOT NULL,
	`createdAt` timestamp DEFAULT (now()),
	CONSTRAINT `chat_messages_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `chat_sessions` (
	`id` varchar(36) NOT NULL,
	`userId` varchar(36) NOT NULL,
	`title` varchar(255),
	`createdAt` timestamp DEFAULT (now()),
	`updatedAt` timestamp DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `chat_sessions_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `community_challenges` (
	`id` varchar(36) NOT NULL,
	`title` varchar(255),
	`description` text,
	`startDate` timestamp,
	`endDate` timestamp,
	`participantsCount` int DEFAULT 0,
	CONSTRAINT `community_challenges_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `dailylogs` (
	`id` varchar(36) NOT NULL,
	`userId` varchar(36),
	`foodItemId` int,
	`mealType` enum('Breakfast','Lunch','Dinner','Snack') NOT NULL,
	`quantity` double NOT NULL,
	`unit` varchar(255) DEFAULT 'g',
	`imageUrl` varchar(255),
	`loggedAt` timestamp DEFAULT (now()),
	CONSTRAINT `dailylogs_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `food_items` (
	`id` int AUTO_INCREMENT NOT NULL,
	`class_name` varchar(255) NOT NULL,
	`avg_height_cm` double NOT NULL DEFAULT 2,
	`density_g_cm3` double NOT NULL DEFAULT 1,
	`protein_per_100g` double NOT NULL DEFAULT 0,
	`carbs_per_100g` double NOT NULL DEFAULT 0,
	`fats_per_100g` double NOT NULL DEFAULT 0,
	`cals_per_100g` double NOT NULL DEFAULT 0,
	`iron_mg` double,
	`sodium_mg` double,
	`servingUnit` varchar(255),
	`barcode` varchar(255),
	`source` enum('USDA','OpenFood','Local','UserCreated'),
	`isVerified` boolean DEFAULT false,
	CONSTRAINT `food_items_id` PRIMARY KEY(`id`),
	CONSTRAINT `food_items_class_name_unique` UNIQUE(`class_name`),
	CONSTRAINT `food_items_barcode_unique` UNIQUE(`barcode`)
);
--> statement-breakpoint
CREATE TABLE `meal_plan_items` (
	`id` varchar(36) NOT NULL,
	`planId` varchar(36),
	`foodItemId` int,
	`recipeId` varchar(36),
	`scheduledDate` date NOT NULL,
	`mealType` enum('Breakfast','Lunch','Dinner','Snack') NOT NULL,
	`isConsumed` boolean DEFAULT false,
	CONSTRAINT `meal_plan_items_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `meal_plans` (
	`id` varchar(36) NOT NULL,
	`userId` varchar(36),
	`name` varchar(255),
	`startDate` date,
	`endDate` date,
	`status` varchar(255),
	`generatedByAI` boolean DEFAULT false,
	CONSTRAINT `meal_plans_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `plans` (
	`id` varchar(36) NOT NULL,
	`name` varchar(255) NOT NULL,
	`monthlyPrice` int NOT NULL,
	`yearlyPrice` int NOT NULL,
	`features` text,
	CONSTRAINT `plans_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `recipe_ingredients` (
	`id` varchar(36) NOT NULL,
	`recipeId` varchar(36),
	`foodItemId` int,
	`quantity` double NOT NULL,
	`unit` varchar(255) NOT NULL,
	CONSTRAINT `recipe_ingredients_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `recipes` (
	`id` varchar(36) NOT NULL,
	`authorId` varchar(36),
	`name` varchar(255) NOT NULL,
	`description` text,
	`instructions` text,
	`prepTimeMinutes` int,
	`cookTimeMinutes` int,
	`isPublic` boolean DEFAULT false,
	`totalCalories` int,
	`totalProtein` double,
	CONSTRAINT `recipes_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `shopping_list` (
	`id` varchar(36) NOT NULL,
	`userId` varchar(36),
	`foodItemId` int,
	`quantity` double,
	`unit` varchar(255),
	`isPurchased` boolean DEFAULT false,
	`talabatLink` varchar(255),
	CONSTRAINT `shopping_list_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `symptom_logs` (
	`id` varchar(36) NOT NULL,
	`userId` varchar(36),
	`symptom` varchar(255) NOT NULL,
	`severity` int,
	`notes` text,
	`loggedAt` timestamp DEFAULT (now()),
	CONSTRAINT `symptom_logs_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `user_badges` (
	`id` varchar(36) NOT NULL,
	`userId` varchar(36),
	`badgeId` varchar(36),
	`earnedAt` timestamp DEFAULT (now()),
	CONSTRAINT `user_badges_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `user_challenges` (
	`userId` varchar(36) NOT NULL,
	`challengeId` varchar(36) NOT NULL,
	`progress` double,
	`status` enum('Joined','Completed') NOT NULL DEFAULT 'Joined',
	CONSTRAINT `user_challenges_userId_challengeId_pk` PRIMARY KEY(`userId`,`challengeId`)
);
--> statement-breakpoint
CREATE TABLE `user_dietary_preferences` (
	`id` varchar(36) NOT NULL,
	`userId` varchar(36) NOT NULL,
	`isVegetarian` boolean,
	`isVegan` boolean,
	`isKeto` boolean,
	`isPaleo` boolean,
	`isGlutenFree` boolean,
	`isHalal` boolean,
	`isPescatarian` boolean,
	`isGlp1User` boolean,
	CONSTRAINT `user_dietary_preferences_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `user_logins` (
	`id` varchar(36) NOT NULL,
	`userId` varchar(36) NOT NULL,
	`lastLogin` timestamp NOT NULL,
	`streak` int NOT NULL DEFAULT 0,
	CONSTRAINT `user_logins_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `usermedicalconditions` (
	`id` varchar(36) NOT NULL,
	`userId` varchar(36) NOT NULL,
	`isDiabetesType1` boolean,
	`isDiabetesType2` boolean,
	`isHypertension` boolean,
	`isPCOS` boolean,
	`isAnemia` boolean,
	`isCeliacDisease` boolean,
	`isIBS` boolean,
	CONSTRAINT `usermedicalconditions_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `user_subscriptions` (
	`id` varchar(36) NOT NULL,
	`userId` varchar(36),
	`planId` varchar(36),
	`status` varchar(255),
	`startDate` timestamp,
	`endDate` timestamp,
	CONSTRAINT `user_subscriptions_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `usertarget` (
	`id` varchar(36) NOT NULL,
	`userId` varchar(36) NOT NULL,
	`calTotal` int NOT NULL,
	`proteins` int NOT NULL,
	`carbs` int NOT NULL,
	`fats` int NOT NULL,
	`iron_mg` double,
	`sodium_mg` double,
	`vitamin_d_iu` double,
	`water_ml` int DEFAULT 2000,
	CONSTRAINT `usertarget_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `users` (
	`id` varchar(36) NOT NULL,
	`name` varchar(255) NOT NULL,
	`password` varchar(255) NOT NULL,
	`email` varchar(255) NOT NULL,
	`googleId` varchar(255),
	`avatar` varchar(255),
	`role` enum('User','Admin','ContentManager') NOT NULL DEFAULT 'User',
	`height` double,
	`weight` double,
	`BMI` double,
	`gender` enum('Male','Female'),
	`age` int NOT NULL,
	`activityLevel` enum('Sedentary','LightlyActive','ModeratelyActive','VeryActive'),
	`xp` int NOT NULL DEFAULT 0,
	`userGoal` enum('WeightLoss','Maintenance','MuscleGain'),
	`created_at` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `users_id` PRIMARY KEY(`id`),
	CONSTRAINT `users_email_unique` UNIQUE(`email`)
);
--> statement-breakpoint
CREATE TABLE `water_logs` (
	`id` varchar(36) NOT NULL,
	`userId` varchar(36),
	`amount_ml` int NOT NULL,
	`loggedAt` timestamp DEFAULT (now()),
	CONSTRAINT `water_logs_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
ALTER TABLE `ai_training_data` ADD CONSTRAINT `ai_training_data_logId_dailylogs_id_fk` FOREIGN KEY (`logId`) REFERENCES `dailylogs`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `chat_messages` ADD CONSTRAINT `chat_messages_sessionId_chat_sessions_id_fk` FOREIGN KEY (`sessionId`) REFERENCES `chat_sessions`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `chat_sessions` ADD CONSTRAINT `chat_sessions_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `dailylogs` ADD CONSTRAINT `dailylogs_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `dailylogs` ADD CONSTRAINT `dailylogs_foodItemId_food_items_id_fk` FOREIGN KEY (`foodItemId`) REFERENCES `food_items`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `meal_plan_items` ADD CONSTRAINT `meal_plan_items_planId_meal_plans_id_fk` FOREIGN KEY (`planId`) REFERENCES `meal_plans`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `meal_plan_items` ADD CONSTRAINT `meal_plan_items_foodItemId_food_items_id_fk` FOREIGN KEY (`foodItemId`) REFERENCES `food_items`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `meal_plan_items` ADD CONSTRAINT `meal_plan_items_recipeId_recipes_id_fk` FOREIGN KEY (`recipeId`) REFERENCES `recipes`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `meal_plans` ADD CONSTRAINT `meal_plans_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `recipe_ingredients` ADD CONSTRAINT `recipe_ingredients_recipeId_recipes_id_fk` FOREIGN KEY (`recipeId`) REFERENCES `recipes`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `recipe_ingredients` ADD CONSTRAINT `recipe_ingredients_foodItemId_food_items_id_fk` FOREIGN KEY (`foodItemId`) REFERENCES `food_items`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `recipes` ADD CONSTRAINT `recipes_authorId_users_id_fk` FOREIGN KEY (`authorId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `shopping_list` ADD CONSTRAINT `shopping_list_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `shopping_list` ADD CONSTRAINT `shopping_list_foodItemId_food_items_id_fk` FOREIGN KEY (`foodItemId`) REFERENCES `food_items`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `symptom_logs` ADD CONSTRAINT `symptom_logs_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `user_badges` ADD CONSTRAINT `user_badges_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `user_badges` ADD CONSTRAINT `user_badges_badgeId_badges_id_fk` FOREIGN KEY (`badgeId`) REFERENCES `badges`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `user_challenges` ADD CONSTRAINT `user_challenges_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `user_challenges` ADD CONSTRAINT `user_challenges_challengeId_community_challenges_id_fk` FOREIGN KEY (`challengeId`) REFERENCES `community_challenges`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `user_dietary_preferences` ADD CONSTRAINT `user_dietary_preferences_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `user_logins` ADD CONSTRAINT `user_logins_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `usermedicalconditions` ADD CONSTRAINT `usermedicalconditions_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `user_subscriptions` ADD CONSTRAINT `user_subscriptions_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `user_subscriptions` ADD CONSTRAINT `user_subscriptions_planId_plans_id_fk` FOREIGN KEY (`planId`) REFERENCES `plans`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `usertarget` ADD CONSTRAINT `usertarget_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `water_logs` ADD CONSTRAINT `water_logs_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;