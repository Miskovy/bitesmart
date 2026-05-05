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
// 1. Check if the user already exists in the database
  const existingUser = await db
    .select()
    .from(users)
    .where(eq(users.email, email));

  if (existingUser.length > 0) {
    throw new BadRequest('User with this email already exists');
  }

  // 2. Hash the password using bcrypt with a salt round of 10
  const hashedPassword = await bcrypt.hash(password, 10);

  // 3. Insert the new user record
  // Note: If your schema requires 'name', ensure it is passed or made optional in schema.ts
  // Cast to any to satisfy the generated insert type when some columns are required by the model.
  await db.insert(users).values({
    email,
    password: hashedPassword,
  } as any);

  return { 
    success: true,
    message: 'User registered successfully' 
  };
};


export const forgetPassword = async (email: string) => {
};

export const verifyResetPasswordCode = async (code: string) => {
};

export const resetPassword = async (token: string, newPassword: string) => {
};






