import { Request , Response } from "express";   
import { BadRequest } from "../../errors";
import { login, loginWithGoogle, register } from "../../services/auth/userAuth.service";
import { SuccessResponse } from "../../utils/Response";


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
    const { email, password, name } = req.body;
    
    if (!email || !password || !name) {
        throw new BadRequest("Email, Password, and Name are required");
    }
    
    const result = await register(email, password, name);
    return SuccessResponse(res, result, 201);
};

export const googleAuth = async (req: Request, res: Response) => {
    const { idToken } = req.body;
    
    if (!idToken) {
        throw new BadRequest("Google ID Token is required");
    }
    
    const result = await loginWithGoogle(idToken);
    
    return SuccessResponse(res, result, 200);
};