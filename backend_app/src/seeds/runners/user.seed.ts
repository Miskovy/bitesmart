import bcrypt from 'bcrypt';
import { eq } from 'drizzle-orm';
import { db } from '../../db/connection';
import { users } from '../../models/user';
import { userTarget } from '../../models/user_target';
import { userMedicalConditions } from '../../models/user_medical_conditions';

export const seedTestUser = async () => {
    try {
        const testEmail = "test@bitesmart.com";

        // Check if user already exists
        const existingUsers = await db.select().from(users).where(eq(users.email, testEmail));
        if (existingUsers.length > 0) {
            console.log(`Test user already exists! User ID: ${existingUsers[0].id}`);
            return existingUsers[0].id;
        }

        console.log("Creating new test user...");
        const hashed_pw = await bcrypt.hash("password123", 10);

        const newUserId = crypto.randomUUID();

        await db.insert(users).values({
            id: newUserId,
            name: "Miskovy",
            password: hashed_pw,
            email: testEmail,
            gender: "Male",
            age: 23,
            userGoal: "WeightLoss"
        });

        await db.insert(userTarget).values({
            userId: newUserId,
            calTotal: 1800,
            proteins: 160,
            carbs: 150,
            fats: 60
        });

        await db.insert(userMedicalConditions).values({
            userId: newUserId,
            isAnemia: true,  // The AI should recommend Iron
            isHypertension: true  // The AI should warn against high sodium
        });

        console.log("✅ Test User successfully seeded!");
        console.log(`🎯 YOUR POSTMAN USER ID IS: ${newUserId}`);

        return newUserId;
    } catch (error) {
        console.error(`❌ Seeding User failed:`, error);
        throw error;
    }
};