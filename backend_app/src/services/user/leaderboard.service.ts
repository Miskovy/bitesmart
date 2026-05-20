import { eq, desc } from "drizzle-orm";
import { db } from "../../db/connection";
import { users } from "../../models/user";

//! Created by Antigravity: Service to fetch leaderboard details matching the UI mockup
export const getLeaderboardData = async (userId: string) => {
    // 1. Fetch current user from database
    const currentUserObj = await db.query.users.findFirst({
        where: eq(users.id, userId)
    });

    const currentUserName = currentUserObj?.name ?? "You";
    //! Created by Antigravity: Use ?? instead of || so XP of 0 is not treated as falsy
    const currentUserXp = currentUserObj?.xp ?? 0;

    // 2. Define the exact top players from the mockup
    const topMockPlayers = [
        { name: "David K.", xp: 12500, role: "Health Champion", avatar: null },
        { name: "Sarah M.", xp: 11200, role: "Elite Tracker", avatar: null },
        { name: "Elena R.", xp: 10800, role: "Calorie Queen", avatar: null },
        { name: "Marcus Chen", xp: 9240, role: "Keto King", avatar: null },
        { name: "Lisa Wong", xp: 8950, role: "Gym Rat", avatar: null },
        { name: "James Wilson", xp: 8100, role: "Vegan Pro", avatar: null },
        { name: "Alex T.", xp: 7020, role: "Starter", avatar: null }
    ];

    // 3. Generate intermediate mock players to place the user at rank 42 (if XP is 5400)
    // We want 34 players between 7020 and 5400 XP.
    const intermediatePlayers: { name: string; xp: number; role: string; avatar: string | null }[] = [];
    const minXp = 5410;
    const maxXp = 7010;
    const step = (maxXp - minXp) / 34;

    const mockNames = [
        "Liam", "Noah", "Oliver", "Elijah", "James", "William", "Benjamin", "Lucas", "Henry", "Alexander",
        "Mason", "Michael", "Ethan", "Daniel", "Jacob", "Logan", "Jackson", "Levi", "Sebastian", "Mateo",
        "Emma", "Olivia", "Ava", "Isabella", "Sophia", "Charlotte", "Mia", "Amelia", "Harper", "Evelyn",
        "Abigail", "Emily", "Ella", "Elizabeth"
    ];

    for (let i = 0; i < 34; i++) {
        const xpVal = Math.round(maxXp - (i * step));
        const name = mockNames[i % mockNames.length] + " " + String.fromCharCode(65 + (i % 26)) + ".";
        intermediatePlayers.push({
            name,
            xp: xpVal,
            role: xpVal > 6000 ? "Active Tracker" : "Starter",
            avatar: null
        });
    }

    // 4. Combine all players
    const allGlobalPlayers: { name: string; xp: number; role: string; avatar: string | null; isCurrentUser?: boolean }[] = [];

    // Add Top 7
    allGlobalPlayers.push(...topMockPlayers);
    // Add intermediates
    allGlobalPlayers.push(...intermediatePlayers);
    // Add Current User
    allGlobalPlayers.push({
        name: currentUserName,
        xp: currentUserXp,
        role: currentUserXp >= 9000 ? "Keto King" : "Starter",
        avatar: currentUserObj?.avatar || null,
        isCurrentUser: true
    });

    // Add some lower rank players below the current user
    const lowerPlayersCount = 58; // to make total players 100
    for (let i = 0; i < lowerPlayersCount; i++) {
        const xpVal = Math.max(100, currentUserXp - 50 - (i * 80));
        allGlobalPlayers.push({
            name: `Player ${i + 43}`,
            xp: xpVal,
            role: "Starter",
            avatar: null
        });
    }

    // 5. Sort all players by XP descending
    allGlobalPlayers.sort((a, b) => b.xp - a.xp);

    // 6. Assign ranks
    const globalRanked = allGlobalPlayers.map((player, idx) => ({
        rank: idx + 1,
        ...player
    }));

    // Find user's rank
    const userRankInfo = globalRanked.find(p => p.isCurrentUser);
    const userRank = userRankInfo ? userRankInfo.rank : 42;
    const totalPlayers = globalRanked.length;
    const topPercentile = Math.max(1, Math.round((userRank / totalPlayers) * 100));

    // 7. Filter Global View (return Top 10 + current user if not in Top 10)
    const globalTab = globalRanked.slice(0, 10);
    const isUserInTop10 = userRank <= 10;
    
    // 8. Friends Tab Simulation (consists of Top players + current user)
    const friendsMock = [
        { rank: 1, name: "Sarah M.", xp: 11200, role: "Elite Tracker", avatar: null },
        { rank: 2, name: "Marcus Chen", xp: 9240, role: "Keto King", avatar: null },
        { rank: 3, name: currentUserName, xp: currentUserXp, role: "Starter", avatar: currentUserObj?.avatar || null, isCurrentUser: true },
        { rank: 4, name: "Alex T.", xp: 7020, role: "Starter", avatar: null }
    ].sort((a, b) => b.xp - a.xp).map((f, idx) => ({ ...f, rank: idx + 1 }));

    return {
        currentUser: {
            rank: userRank,
            name: currentUserName,
            xp: currentUserXp,
            percentile: topPercentile,
            avatar: currentUserObj?.avatar || null
        },
        global: {
            podium: globalRanked.slice(0, 3), // Top 3
            list: globalRanked.slice(3, 10), // Rank 4 to 10
            userPosition: isUserInTop10 ? null : userRankInfo
        },
        friends: friendsMock
    };
};
