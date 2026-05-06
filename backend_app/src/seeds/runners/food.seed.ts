import { eq } from 'drizzle-orm';
import { db } from '../../db/connection';
import { foodItems } from '../../models/food_items';
import { REAL_FOOD_DATA } from '../data/food.data';

export const seedFoodItems = async () => {
    try {
        console.log("Seeding food database...");

        const classNames = Object.keys(REAL_FOOD_DATA);

        for (const className of classNames) {
            const existingItem = await db.select().from(foodItems).where(eq(foodItems.class_name, className));
            if (existingItem.length > 0) {
                continue;
            }

            const data = REAL_FOOD_DATA[className];

            await db.insert(foodItems).values({
                class_name: className,
                avg_height_cm: data.height,
                density_g_cm3: data.density,
                protein_per_100g: data.pro,
                carbs_per_100g: data.carbs,
                fats_per_100g: data.fat,
                cals_per_100g: data.cals,
                source: "USDA"
            });
        }

        console.log(`✅ Successfully seeded ${classNames.length} classes with real data into bitesmartDB!`);
    } catch (e) {
        console.error(`❌ Error seeding database:`, e);
        throw e;
    }
};