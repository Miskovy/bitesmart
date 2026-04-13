import { AppError } from "./AppError";
import { StatusCodes } from "http-status-codes";

export class UnauthorizedError extends AppError {
    constructor(message = "Uanauthorized Access", details?: any) {
        super(message, StatusCodes.UNAUTHORIZED, details);
    }
}