import { eq, and, gte, lte } from "drizzle-orm";
import { db } from "../../db/connection";
import { symptomLogs } from "../../models/symptom_logs";
import { BadRequest } from "../../errors";

//! Created by Antigravity: Service to log a GLP-1 symptom (Nausea, Appetite, etc.)
export const logSymptom = async (
    userId: string,
    symptom: string,
    severity: number,
    notes?: string
) => {
    if (severity < 0 || severity > 4) {
        throw new BadRequest("Severity must be between 0 and 4");
    }

    await db.insert(symptomLogs).values({
        userId,
        symptom,
        severity,
        notes: notes || null,
    });

    return {
        message: "Symptom logged successfully",
        symptom,
        severity,
    };
};

//! Created by Antigravity: Service to log the full GLP-1 daily check-in (Nausea + Appetite)
export const logDailyCheckIn = async (
    userId: string,
    nauseaLevel: number,
    appetiteLevel: number,
    notes?: string
) => {
    const results = await Promise.all([
        logSymptom(userId, "Nausea", nauseaLevel, notes),
        logSymptom(userId, "Appetite", appetiteLevel, notes),
    ]);

    return {
        message: "Daily check-in logged successfully",
        nausea: results[0],
        appetite: results[1],
    };
};

//! Created by Antigravity: Service to get symptom logs for a specific date
export const getSymptomsByDate = async (userId: string, dateStr: string) => {
    const startOfDay = new Date(dateStr);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(dateStr);
    endOfDay.setHours(23, 59, 59, 999);

    const logs = await db
        .select()
        .from(symptomLogs)
        .where(
            and(
                eq(symptomLogs.userId, userId),
                gte(symptomLogs.loggedAt, startOfDay),
                lte(symptomLogs.loggedAt, endOfDay)
            )
        );

    return logs;
};

//! Created by Antigravity: Service to get symptom history with pagination
export const getSymptomHistory = async (userId: string, page: number = 1, limit: number = 20) => {
    const offset = (page - 1) * limit;

    const logs = await db
        .select()
        .from(symptomLogs)
        .where(eq(symptomLogs.userId, userId))
        .orderBy(symptomLogs.loggedAt)
        .limit(limit)
        .offset(offset);

    return logs;
};
