import { aiApiRequest, aiApiStreamRequest } from "../api/apiRequest.service";
import { db } from "../../db/connection";
import { userTarget } from "../../models/user_target";
import { eq } from "drizzle-orm";
import { calculateUserTargets } from "./target.service";

const ensureUserTargets = async (userId: string) => {
    const existing = await db.query.userTarget.findFirst({
        where: eq(userTarget.userId, userId)
    });
    if (!existing) {
        try {
            await calculateUserTargets(userId);
        } catch (error) {
            // If we can't calculate targets (e.g. incomplete profile), the AI will still fail,
            // but we at least attempted to heal it. We let the original error bubble up or let the AI handle it.
            console.error("Failed to auto-calculate targets:", error);
        }
    }
};

//! Created by Antigravity: Updated to support search, pagination, and category filtering
export const getAllChats = async (
    userId: string,
    params?: { search?: string; page?: number; limit?: number; category?: string }
) => {
    const query = new URLSearchParams();
    query.append("user_id", userId);
    if (params?.search) query.append("search", params.search);
    if (params?.page) query.append("page", params.page.toString());
    if (params?.limit) query.append("limit", params.limit.toString());
    if (params?.category) query.append("category", params.category);
    return await aiApiRequest(`/coach/sessions?${query.toString()}`, "GET");
};

export const getChatMessages = async (userId: string, chatId: string) => {
    return await aiApiRequest(`/coach/sessions/${chatId}/history?user_id=${userId}`, "GET");
};

export const sendMessage = async (userId: string, message: string, chatId?: string) => {
    await ensureUserTargets(userId);
    
    const payload: any = {
        user_id: userId,
        message: message,
    };
    if (chatId) {
        payload.session_id = chatId;
    }
    return await aiApiRequest(`/coach/chat`, "POST", payload);
};
export const sendMessageStream = async (userId: string, message: string, chatId?: string) => {
    await ensureUserTargets(userId);

    const payload: any = {
        user_id: userId,
        message: message,
    };
    if (chatId) {
        payload.session_id = chatId;
    }
    return await aiApiStreamRequest(`/coach/chat/stream`, "POST", payload);
};

export const deleteChat = async (userId: string, chatId: string) => {
    return await aiApiRequest(`/coach/sessions/${chatId}?user_id=${userId}`, "DELETE");
};