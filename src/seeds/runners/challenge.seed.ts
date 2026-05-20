import { db } from '../../db/connection';
import { communityChallenges } from '../../models/community_challenges';
import { eq } from 'drizzle-orm';

export const seedCommunityChallenges = async () => {
    try {
        //! Created by Antigravity: Define the default challenges from the UI mockups
        const defaultChallenges = [
            {
                title: "7-Day Sugar-Free",
                description: "Reset your insulin levels and energy by avoiding refined sugar.",
                startDate: new Date(),
                endDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
                participantsCount: 1540
            },
            {
                title: "Walk 10k Steps",
                description: "Walk 10,000 steps daily to build heart health and clear your mind.",
                startDate: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
                endDate: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000),
                participantsCount: 1200
            },
            {
                title: "Hydration Station",
                description: "Build a solid habit of drinking water regularly.",
                startDate: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
                endDate: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000),
                participantsCount: 3000
            },
            {
                title: "Mindful Minutes",
                description: "Spend 10 minutes a day meditating or breathing mindfully.",
                startDate: new Date(Date.now() + 1 * 24 * 60 * 60 * 1000),
                endDate: new Date(Date.now() + 11 * 24 * 60 * 60 * 1000),
                participantsCount: 240
            }
        ];

        console.log("Seeding community challenges...");

        for (const challenge of defaultChallenges) {
            const existing = await db.select()
                .from(communityChallenges)
                .where(eq(communityChallenges.title, challenge.title));
            
            if (existing.length === 0) {
                await db.insert(communityChallenges).values(challenge);
                console.log(`Seeded challenge: ${challenge.title}`);
            } else {
                console.log(`Challenge already exists: ${challenge.title}`);
            }
        }

        console.log("✅ Community challenges seeding finished successfully!");
    } catch (error) {
        console.error("❌ Seeding community challenges failed:", error);
        throw error;
    }
};
