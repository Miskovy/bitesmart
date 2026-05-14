import { aiApiRequest, aiApiStreamRequest } from "../api/apiRequest.service";

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

export const sendMessage = async (userId: string, message: string, chatId: string) => {
    return await aiApiRequest(`/coach/chat`, "POST", {
        user_id: userId,
        message: message,
        session_id: chatId
    });
};
export const sendMessageStream = async (userId: string, message: string, chatId?: string) => {
    return await aiApiStreamRequest(`/coach/chat/stream`, "POST", {
        user_id: userId,
        message: message,
        session_id: chatId
    });
};

export const deleteChat = async (userId: string, chatId: string) => {
    return await aiApiRequest(`/coach/sessions/${chatId}?user_id=${userId}`, "DELETE");
};