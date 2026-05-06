ALTER TABLE `food_items` MODIFY COLUMN `class_name` varchar(255) NOT NULL;--> statement-breakpoint
ALTER TABLE `food_items` MODIFY COLUMN `avg_height_cm` double NOT NULL DEFAULT 2;--> statement-breakpoint
ALTER TABLE `food_items` MODIFY COLUMN `density_g_cm3` double NOT NULL DEFAULT 1;--> statement-breakpoint
ALTER TABLE `food_items` MODIFY COLUMN `protein_per_100g` double NOT NULL;--> statement-breakpoint
ALTER TABLE `food_items` MODIFY COLUMN `carbs_per_100g` double NOT NULL;--> statement-breakpoint
ALTER TABLE `food_items` MODIFY COLUMN `fats_per_100g` double NOT NULL;--> statement-breakpoint
ALTER TABLE `food_items` MODIFY COLUMN `cals_per_100g` double NOT NULL;--> statement-breakpoint
ALTER TABLE `food_items` MODIFY COLUMN `iron_mg` double;--> statement-breakpoint
ALTER TABLE `food_items` MODIFY COLUMN `sodium_mg` double;--> statement-breakpoint
ALTER TABLE `food_items` MODIFY COLUMN `servingUnit` varchar(255);--> statement-breakpoint
ALTER TABLE `food_items` MODIFY COLUMN `barcode` varchar(255);