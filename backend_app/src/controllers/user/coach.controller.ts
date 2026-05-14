import { Request, Response } from "express";
import { getAllChats, getChatMessages , deleteChat, sendMessage, sendMessageStream as sendMessageStreamService } from "../../services/user/coach.service";
import { BadRequest, UnauthorizedError } from "../../errors";
import { SuccessResponse } from "../../utils/Response";

//! Created by Antigravity: Updated to support search, pagination, and category query params
export const getAllUserChats = async (req: Request, res: Response) => {
    const userId = req.user?.id;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    const { search, page, limit, category } = req.query;

    const chats = await getAllChats(userId, {
        search: search as string | undefined,
        page: page ? Number(page) : undefined,
        limit: limit ? Number(limit) : undefined,
        category: category as string | undefined,
    });

    SuccessResponse(res, chats);
};

export const getUserChatMessages = async (req: Request, res: Response) => {
    const userId = req.user?.id;
    const { chatId } = req.params;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    if (!chatId) {
        throw new BadRequest("Invalid Chat ID");
    }

    const chat = await getChatMessages(userId, chatId as string);

    SuccessResponse(res, chat);
};


export const deleteUserChat = async (req: Request, res: Response) => {
    const userId = req.user?.id;
    const { chatId } = req.params;

    if(!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    if(!chatId) {
        throw new BadRequest("Invalid Chat ID");
    }

    const deleted = await deleteChat(userId, chatId as string);

    if (!deleted) {
        throw new BadRequest("Failed to delete chat");
    }

    SuccessResponse(res, { message: "Chat deleted successfully" }, 204);
};

export const sendUserMessage = async (req: Request, res: Response) => {
    const userId = req.user?.id;
    const { message, chatId } = req.body;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    if (!message) {
        throw new BadRequest("Message is required");
    }

    const response = await sendMessage(userId, message, chatId);

    SuccessResponse(res, response);
};

export const sendUserMessageStream = async (req: Request, res: Response) => {
    const userId = req.user?.id;
    const { message, chatId } = req.body;

    if (!userId) {
        throw new UnauthorizedError("Invalid User");
    }

    if (!message) {
        throw new BadRequest("Message is required");
    }

    const stream = await sendMessageStreamService(userId, message, chatId);

    res.setHeader("Content-Type", "text/event-stream");
    res.setHeader("Cache-Control", "no-cache");
    res.setHeader("Connection", "keep-alive");

    stream.pipe(res);
};