import { eq, and, sql, or, like, desc, count } from "drizzle-orm";
import { db } from "../../db/connection";
import { communityChallenges } from "../../models/community_challenges";
import { userChallenges } from "../../models/user_challenges";
import { BadRequest, NotFound } from "../../errors";

//! Created by Antigravity: Service to fetch all community challenges with join status and user progress
export const getChallenges = async (userId: string) => {
    const challengesList = await db.select().from(communityChallenges);

    const userJoins = await db.select()
        .from(userChallenges)
        .where(eq(userChallenges.userId, userId));

    const joinsMap = new Map(userJoins.map(j => [j.challengeId, j]));

    return challengesList.map(ch => {
        const userJoin = joinsMap.get(ch.id);
        const daysLeft = ch.endDate 
            ? Math.max(0, Math.ceil((new Date(ch.endDate).getTime() - Date.now()) / (1000 * 60 * 60 * 24)))
            : null;

        return {
            id: ch.id,
            title: ch.title,
            description: ch.description,
            startDate: ch.startDate,
            endDate: ch.endDate,
            participantsCount: ch.participantsCount || 0,
            daysLeft,
            isJoined: !!userJoin,
            progress: userJoin ? (userJoin.progress || 0) : null,
            status: userJoin ? userJoin.status : null
        };
    });
};

//! Created by Antigravity: Service to join a community challenge
export const joinChallenge = async (userId: string, challengeId: string) => {
    // 1. Verify challenge exists
    const challenge = await db.query.communityChallenges.findFirst({
        where: eq(communityChallenges.id, challengeId)
    });

    if (!challenge) {
        throw new NotFound("Challenge not found");
    }

    // 2. Check if already joined
    const existing = await db.query.userChallenges.findFirst({
        where: and(
            eq(userChallenges.userId, userId),
            eq(userChallenges.challengeId, challengeId)
        )
    });

    if (existing) {
        throw new BadRequest("You have already joined this challenge");
    }

    // 3. Register user
    const newJoinId = crypto.randomUUID();
    await db.insert(userChallenges).values({
        id: newJoinId,
        userId,
        challengeId,
        progress: 0,
        status: 'Joined'
    });

    // 4. Increment participant count
    await db.update(communityChallenges)
        .set({
            participantsCount: sql`${communityChallenges.participantsCount} + 1`
        })
        .where(eq(communityChallenges.id, challengeId));

    return {
        message: "Successfully joined challenge",
        challengeId,
        progress: 0,
        status: "Joined"
    };
};

//! Created by Antigravity: Service to leave a community challenge
export const leaveChallenge = async (userId: string, challengeId: string) => {
    // 1. Verify join exists
    const existing = await db.query.userChallenges.findFirst({
        where: and(
            eq(userChallenges.userId, userId),
            eq(userChallenges.challengeId, challengeId)
        )
    });

    if (!existing) {
        throw new NotFound("You have not joined this challenge");
    }

    // 2. Delete join record
    await db.delete(userChallenges)
        .where(and(
            eq(userChallenges.userId, userId),
            eq(userChallenges.challengeId, challengeId)
        ));

    // 3. Decrement participant count
    await db.update(communityChallenges)
        .set({
            participantsCount: sql`GREATEST(0, ${communityChallenges.participantsCount} - 1)`
        })
        .where(eq(communityChallenges.id, challengeId));

    return {
        message: "Successfully left challenge"
    };
};

//! Created by Antigravity: Service to update user progress in a challenge
export const updateChallengeProgress = async (userId: string, challengeId: string, progress: number) => {
    if (progress < 0 || progress > 100) {
        throw new BadRequest("Progress percentage must be between 0 and 100");
    }

    // 1. Verify join exists
    const existing = await db.query.userChallenges.findFirst({
        where: and(
            eq(userChallenges.userId, userId),
            eq(userChallenges.challengeId, challengeId)
        )
    });

    if (!existing) {
        throw new NotFound("You have not joined this challenge");
    }

    const status = progress >= 100 ? 'Completed' : 'Joined';

    // 2. Update progress
    await db.update(userChallenges)
        .set({
            progress,
            status
        })
        .where(and(
            eq(userChallenges.userId, userId),
            eq(userChallenges.challengeId, challengeId)
        ));

    return {
        message: "Progress updated successfully",
        challengeId,
        progress,
        status
    };
};

/**
 * Creates a new community challenge.
 * 
 * @param title - Title of the challenge.
 * @param description - Description of the challenge.
 * @param startDate - Optional start date.
 * @param endDate - Optional end date.
 * @returns The created challenge object.
 */
export const createChallenge = async (
    title: string,
    description: string,
    startDate?: string | Date,
    endDate?: string | Date
) => {
    if (!title || !description) {
        throw new BadRequest("Title and Description are required");
    }

    const start = startDate ? new Date(startDate) : new Date();
    const end = endDate ? new Date(endDate) : null;

    const challengeId = crypto.randomUUID();

    await db.insert(communityChallenges).values({
        id: challengeId,
        title,
        description,
        startDate: start,
        endDate: end,
        participantsCount: 0
    });

    return {
        id: challengeId,
        title,
        description,
        startDate: start,
        endDate: end,
        participantsCount: 0
    };
};

/* ==========================================
   ADMINISTRATIVE CHALLENGES CRUD OPERATIONS
   ========================================== */

/**
 * Get all community challenges with pagination and search for admin panel
 */
export const getAllChallengesAdmin = async ({
    page = 1,
    pageSize = 10,
    query,
}: {
    page?: number;
    pageSize?: number;
    query?: string;
}) => {
    const skip = (page - 1) * pageSize;

    const whereClause = query
        ? or(
              like(communityChallenges.title, `%${query}%`),
              like(communityChallenges.description, `%${query}%`)
          )
        : undefined;

    const totalResult = await db
        .select({ value: count() })
        .from(communityChallenges)
        .where(whereClause);

    const total = totalResult[0]?.value || 0;

    const challengesList = await db.query.communityChallenges.findMany({
        where: whereClause,
        limit: pageSize,
        offset: skip,
        orderBy: [desc(communityChallenges.startDate)],
    });

    return {
        challenges: challengesList,
        total,
        page,
        pageSize,
    };
};

/**
 * Get a single community challenge by ID for admin panel
 */
export const getChallengeByIdAdmin = async (id: string) => {
    const challenge = await db.query.communityChallenges.findFirst({
        where: eq(communityChallenges.id, id),
    });

    if (!challenge) {
        throw new NotFound(`Challenge with ID ${id} not found`);
    }

    return challenge;
};

/**
 * Update an existing community challenge
 */
export const updateChallenge = async (id: string, data: any) => {
    const challenge = await db.query.communityChallenges.findFirst({
        where: eq(communityChallenges.id, id),
    });

    if (!challenge) {
        throw new NotFound(`Challenge with ID ${id} not found`);
    }

    const updates: any = {};
    if (data.title !== undefined) updates.title = data.title;
    if (data.description !== undefined) updates.description = data.description;
    if (data.startDate !== undefined) updates.startDate = data.startDate ? new Date(data.startDate) : null;
    if (data.endDate !== undefined) updates.endDate = data.endDate ? new Date(data.endDate) : null;
    if (data.participantsCount !== undefined) updates.participantsCount = data.participantsCount;

    if (Object.keys(updates).length > 0) {
        await db.update(communityChallenges).set(updates).where(eq(communityChallenges.id, id));
    }

    const updatedChallenge = await db.query.communityChallenges.findFirst({
        where: eq(communityChallenges.id, id),
    });

    if (!updatedChallenge) {
        throw new BadRequest("Failed to retrieve updated challenge");
    }

    return updatedChallenge;
};

/**
 * Delete a community challenge and its user participation records
 */
export const deleteChallenge = async (id: string) => {
    const challenge = await db.query.communityChallenges.findFirst({
        where: eq(communityChallenges.id, id),
    });

    if (!challenge) {
        throw new NotFound(`Challenge with ID ${id} not found`);
    }

    await db.transaction(async (tx) => {
        // 1. Delete user participation records
        await tx.delete(userChallenges).where(eq(userChallenges.challengeId, id));

        // 2. Delete the community challenge itself
        await tx.delete(communityChallenges).where(eq(communityChallenges.id, id));
    });

    return { id, message: "Challenge and all related participant records deleted successfully" };
};

