import { Router } from "express";
import { getAllUserChats, getUserChatMessages, deleteUserChat, sendUserMessage, sendUserMessageStream } from "../../controllers/user/coach.controller";
import catchAsync from "../../utils/catchAsync";

const router = Router();

router.get("/sessions", catchAsync(getAllUserChats));
router.get("/sessions/:chatId/history", catchAsync(getUserChatMessages));
router.delete("/sessions/:chatId", catchAsync(deleteUserChat));

router.post("/chat", catchAsync(sendUserMessage));
router.post("/chat/stream", catchAsync(sendUserMessageStream));

export default router;
