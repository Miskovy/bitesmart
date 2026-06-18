CREATE TABLE `weight_logs` (
	`id` varchar(36) NOT NULL,
	`userId` varchar(36) NOT NULL,
	`weight` double NOT NULL,
	`loggedAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `weight_logs_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
ALTER TABLE `users` MODIFY COLUMN `avatar` mediumtext;--> statement-breakpoint
ALTER TABLE `ai_training_data` ADD `userId` varchar(36);--> statement-breakpoint
ALTER TABLE `ai_training_data` ADD `createdAt` timestamp DEFAULT (now()) NOT NULL;--> statement-breakpoint
ALTER TABLE `weight_logs` ADD CONSTRAINT `weight_logs_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `ai_training_data` ADD CONSTRAINT `ai_training_data_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;