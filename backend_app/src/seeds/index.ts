import 'dotenv/config';
import { seedTestUser } from './runners/user.seed';
import { seedFoodItems } from './runners/food.seed';
//! Created by Antigravity: Import challenge seed runner
import { seedCommunityChallenges } from './runners/challenge.seed';

const runSeeds = async () => {
    try {
        await seedTestUser();
        await seedFoodItems();
        //! Created by Antigravity: Seed community challenges
        await seedCommunityChallenges();
        console.log("✅ All seeds finished successfully!");
    } catch (e) {
        console.error("Failed to seed correctly", e);
    } finally {
        process.exit(0);
    }
};

runSeeds();
