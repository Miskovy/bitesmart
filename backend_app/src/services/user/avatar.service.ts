import { eq } from "drizzle-orm";
import { db } from "../../db/connection";
import { users } from "../../models/user";
import { BadRequest } from "../../errors";
import { bufferToBase64 } from "../../utils/base64";

export const uploadAvatar = async (userId: string, file: Express.Multer.File) => {
    if (!file) {
        throw new BadRequest("No file uploaded");
    }

    // Validate file type
    const allowedTypes = ["image/jpeg", "image/png", "image/webp"];
    if (!allowedTypes.includes(file.mimetype)) {
        throw new BadRequest("Invalid file type. Only JPEG, PNG, and WebP are allowed.");
    }

    // Convert file buffer to Base64 Data URI
    const base64Data = bufferToBase64(file.buffer, file.mimetype);

    await db.update(users)
        .set({ avatar: base64Data })
        .where(eq(users.id, userId));

    return {
        message: "Avatar uploaded successfully",
        avatarUrl: base64Data,
    };
};
