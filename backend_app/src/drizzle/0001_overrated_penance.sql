ALTER TABLE `food_items` MODIFY COLUMN `class_name` varchar(100) NOT NULL;--> statement-breakpoint
ALTER TABLE `food_items` MODIFY COLUMN `avg_height_cm` float NOT NULL DEFAULT 2;--> statement-breakpoint
ALTER TABLE `food_items` MODIFY COLUMN `density_g_cm3` float NOT NULL DEFAULT 1;--> statement-breakpoint
ALTER TABLE `food_items` MODIFY COLUMN `protein_per_100g` float NOT NULL;--> statement-breakpoint
ALTER TABLE `food_items` MODIFY COLUMN `carbs_per_100g` float NOT NULL;--> statement-breakpoint
ALTER TABLE `food_items` MODIFY COLUMN `fats_per_100g` float NOT NULL;--> statement-breakpoint
ALTER TABLE `food_items` MODIFY COLUMN `cals_per_100g` float NOT NULL;--> statement-breakpoint
ALTER TABLE `food_items` MODIFY COLUMN `iron_mg` float;--> statement-breakpoint
ALTER TABLE `food_items` MODIFY COLUMN `sodium_mg` float;--> statement-breakpoint
ALTER TABLE `food_items` MODIFY COLUMN `servingUnit` varchar(50);--> statement-breakpoint
ALTER TABLE `food_items` MODIFY COLUMN `barcode` varchar(100);