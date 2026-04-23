import { Request , Response } from "express";   
import { BadRequest } from "../../errors";
import { login } from "../../services/auth/userAuth.service";
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

