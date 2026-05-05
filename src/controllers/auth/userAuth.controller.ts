import { Request , Response } from "express";   
import { BadRequest } from "../../errors";
import { login } from "../../services/auth/userAuth.service";
import { SuccessResponse } from "../../utils/Response";
import {register} from '../../services/auth/userAuth.service';


export const userLogin = async (req: Request, res: Response) => {
    const { email, password } = req.body;

    if (!email || !password) {
        throw new BadRequest("Email and Password are required");
    }

    const { user, token } = await login(email, password);

    return SuccessResponse(res, {
        user: {
            name : user.name,
            email: user.email,
        },
        token,
    }, 200);
};

export const signup = async (req: Request, res: Response) => {
    const { email, password } = req.body;

    // 1. Explicit validation check
    if (!email || !password) {
        throw new BadRequest("Email and Password are required");
    }

    // 2. Call the service to register the user
    const result = await register(email, password);

    // 3. Return a standardized success response
    return SuccessResponse(res, {
        message: result.message
    }, 201);
};
