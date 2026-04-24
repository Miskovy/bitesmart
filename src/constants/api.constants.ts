import dotenv from "dotenv";


dotenv.config();

export const aiBaseurl = process.env.AI_BASE_URL ? process.env.AI_BASE_URL : "";
export const aiApiKey = process.env.AI_API_KEY ? process.env.AI_API_KEY : "";
export const aiApiSecret = process.env.AI_API_SECRET ? process.env.AI_API_SECRET : "";

