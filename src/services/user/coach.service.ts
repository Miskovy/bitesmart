import { aiApiRequest, aiApiStreamRequest } from "../api/apiRequest.service";

export const getAllChats = async (userId: string) => {
    return await aiApiRequest(`/coach/sessions?user_id=${userId}`, "GET");
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