ALTER TABLE `user_challenges` DROP PRIMARY KEY;--> statement-breakpoint
ALTER TABLE `user_challenges` ADD PRIMARY KEY(`id`);--> statement-breakpoint
ALTER TABLE `user_challenges` ADD `id` varchar(36) NOT NULL;