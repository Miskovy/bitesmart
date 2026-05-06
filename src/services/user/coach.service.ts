export const getChatHistory = async (userId: string) => {};
export const getChatSessions = async (userId: string , chatId: string) => {};
export const sendMessage = async (userId: string, message: string, chatId: string) => {};
export const sendMessageStream = async (userId: string, message: string, chatId: string) => {};
export const deleteChat = async (userId: string, chatId: string): Promise<boolean> => { return true; };