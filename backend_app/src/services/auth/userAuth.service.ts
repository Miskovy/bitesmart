import { db } from "../../db/connection";
import { BadRequest } from "../../errors";
import { users } from "../../models/user";
import { eq } from "drizzle-orm";
import bcrypt from "bcrypt";
import { generateToken } from "../../utils/Auth";

export const login = async (email: string, password: string) => {
    const user = await db.query.users.findFirst({
        where: eq(users.email, email),
    });

    if (!user) {
        throw new BadRequest("Invalid Credentials");
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
        throw new BadRequest("Invalid Credentials");
    }

    const token = generateToken({
        id   : user.id,
        name : user.name,
        email: user.email,
    });

    return { user, token };
};


// TODO : Register
export const register = async (email: string, password: string) => {

};


export const forgetPassword = async (email: string) => {
};

export const verifyResetPasswordCode = async (code: string) => {
};

export const resetPassword = async (token: string, newPassword: string) => {
};






