CREATE TABLE `health_sync` (
	`id` varchar(36) NOT NULL,
	`userId` varchar(36) NOT NULL,
	`activeCaloriesBurned` int DEFAULT 0,
	`steps` int DEFAULT 0,
	`syncDate` date NOT NULL,
	`updatedAt` timestamp DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `health_sync_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `completed_days` (
	`id` varchar(36) NOT NULL,
	`userId` varchar(36) NOT NULL,
	`completedDate` varchar(10) NOT NULL,
	`completedAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `completed_days_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
ALTER TABLE `users` ADD `phone` varchar(20);--> statement-breakpoint
ALTER TABLE `users` ADD `notificationsEnabled` boolean DEFAULT false;--> statement-breakpoint
ALTER TABLE `users` ADD `healthDataEnabled` boolean DEFAULT false;--> statement-breakpoint
ALTER TABLE `users` ADD `cameraAccessEnabled` boolean DEFAULT false;--> statement-breakpoint
ALTER TABLE `users` ADD `deviceToken` varchar(255);--> statement-breakpoint
ALTER TABLE `chat_sessions` ADD `category` enum('Advice','Nutrition','General') DEFAULT 'General';--> statement-breakpoint
ALTER TABLE `user_dietary_preferences` ADD `isRamadanMode` boolean;--> statement-breakpoint
ALTER TABLE `user_dietary_preferences` ADD `highProteinGoal` boolean DEFAULT false;--> statement-breakpoint
ALTER TABLE `user_dietary_preferences` ADD `hydrationReminderHours` int DEFAULT 2;--> statement-breakpoint
ALTER TABLE `user_dietary_preferences` ADD `suhoorTime` varchar(10);--> statement-breakpoint
ALTER TABLE `user_dietary_preferences` ADD `iftarTime` varchar(10);--> statement-breakpoint
ALTER TABLE `user_dietary_preferences` ADD `hydrationFocus` boolean DEFAULT false;--> statement-breakpoint
ALTER TABLE `usertarget` ADD `autoCalculateWithAi` boolean DEFAULT true;--> statement-breakpoint
ALTER TABLE `health_sync` ADD CONSTRAINT `health_sync_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `completed_days` ADD CONSTRAINT `completed_days_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;