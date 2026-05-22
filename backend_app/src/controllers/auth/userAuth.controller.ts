import { Request, Response } from "express";
import { BadRequest } from "../../errors";
import {
    forgetPassword,
    login,
    loginWithGoogle,
    register,
    resetPassword,
    verifyResetPasswordCode
} from "../../services/auth/userAuth.service";
import { SuccessResponse } from "../../utils/Response";

export const userLogin = async (req: Request, res: Response) => {
    const { email, password } = req.body;

    if (!email || !password) {
        throw new BadRequest("Email and Password are required");
    }

    const { user, token } = await login(email, password);

    return SuccessResponse(res, {
        user: {
            name: user.name,
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

export const forgotPasswordController = async (req: Request, res: Response) => {
    const { email } = req.body;

    if (!email) {
        throw new BadRequest("Email is required");
    }

    const result = await forgetPassword(email);

    return SuccessResponse(res, result, 200);
};

export const verifyResetCodeController = async (req: Request, res: Response) => {
    const { code } = req.body;

    if (!code) {
        throw new BadRequest("Code is required");
    }

    const result = await verifyResetPasswordCode(code);

    return SuccessResponse(res, result, 200);
};

export const resetPasswordController = async (req: Request, res: Response) => {
    const { token, newPassword } = req.body;

    if (!token || !newPassword) {
        throw new BadRequest("Token and newPassword are required");
    }

    const result = await resetPassword(token, newPassword);

    return SuccessResponse(res, result, 200);
};
