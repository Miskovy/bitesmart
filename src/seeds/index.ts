import 'dotenv/config';
import { seedTestUser } from './runners/user.seed';
import { seedFoodItems } from './runners/food.seed';

const runSeeds = async () => {
    try {
        await seedTestUser();
        await seedFoodItems();
        console.log("✅ All seeds finished successfully!");
    } catch (e) {
        console.error("Failed to seed correctly", e);
    } finally {
        process.exit(0);
    }
};

runSeeds();
