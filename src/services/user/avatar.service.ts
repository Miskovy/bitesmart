import { eq } from "drizzle-orm";
import { db } from "../../db/connection";
import { users } from "../../models/user";
import { BadRequest } from "../../errors";
import path from "path";
import fs from "fs";

//! Created by Antigravity: Service to upload and save user avatar
export const uploadAvatar = async (userId: string, file: Express.Multer.File) => {
    if (!file) {
        throw new BadRequest("No file uploaded");
    }

    // Validate file type
    const allowedTypes = ["image/jpeg", "image/png", "image/webp"];
    if (!allowedTypes.includes(file.mimetype)) {
        throw new BadRequest("Invalid file type. Only JPEG, PNG, and WebP are allowed.");
    }

    // Create uploads directory if it doesn't exist
    const uploadsDir = path.join(process.cwd(), "uploads", "avatars");
    if (!fs.existsSync(uploadsDir)) {
        fs.mkdirSync(uploadsDir, { recursive: true });
    }

    // Generate a unique filename
    const ext = path.extname(file.originalname);
    const filename = `${userId}-${Date.now()}${ext}`;
    const filePath = path.join(uploadsDir, filename);

    // Write the file to disk
    fs.writeFileSync(filePath, file.buffer);

    // Save the relative URL path to the database
    const avatarUrl = `/uploads/avatars/${filename}`;

    await db.update(users)
        .set({ avatar: avatarUrl })
        .where(eq(users.id, userId));

    return {
        message: "Avatar uploaded successfully",
        avatarUrl,
    };
};
