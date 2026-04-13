import { AppError } from "./AppError";
import { StatusCodes } from "http-status-codes";

export class DatabaseError extends AppError {
    constructor(message = "Database Operation Failed", details?: any) {
        super(message, StatusCodes.INTERNAL_SERVER_ERROR, details);
    }
}