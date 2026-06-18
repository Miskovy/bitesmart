import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import { StatusCodes } from "http-status-codes";
import { SuccessResponse } from "./utils/Response";
import { errorHandler } from "./middlewares/ErrorHandler";
import { AppError } from "./errors/AppError";
import { connectToDatabase } from "./db/connection";
import apiRouter from "./routes/index";
import { initFastingCron } from "./cron/fastingJob";

dotenv.config();

const app = express();

// Security Middleware
app.use(helmet());

// CORS Configuration
//! Created by Antigravity: Restrict CORS origin in production instead of wildcard
const allowedOrigins = process.env.CORS_ORIGINS ? process.env.CORS_ORIGINS.split(',').map(o => o.trim()) : ["*"];
app.use(cors({
    origin: allowedOrigins.includes("*") ? "*" : allowedOrigins,
    credentials: !allowedOrigins.includes("*"), //! credentials only work with specific origins
}));

// Logging
app.use(morgan("dev"));

import path from "path";

// Body Parsing
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

//! Created by Antigravity: Serve uploaded files (avatars, etc.) as static assets
app.use("/uploads", express.static(path.join(process.cwd(), "uploads")));

// Serve static assets from public folder (branding logos, email designs, etc.)
app.use("/public", express.static(path.join(process.cwd(), "public")));


// Health Check
app.get("/", (req, res) => {
    SuccessResponse(res, { message: "Bitesmart API is running" }, StatusCodes.OK);
});

// API Routes
app.use("/api", apiRouter);

// 404 Handler
app.use((req, res, next) => {
    next(new AppError(`Route ${req.originalUrl} not found`, StatusCodes.NOT_FOUND));
});

// Global Error Handler
app.use(errorHandler);

connectToDatabase().then(() => {
    initFastingCron();
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});

