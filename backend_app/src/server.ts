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

dotenv.config();

const app = express();

// Security Middleware
app.use(helmet());

// CORS Configuration
app.use(cors({
    origin: "*",
    credentials: true
}));

// Logging
app.use(morgan("dev"));

// Body Parsing
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

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

connectToDatabase();

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});

