import { db } from "../../db/connection";
import { BadRequest } from "../../errors";
import { users } from "../../models/user";
import { eq } from "drizzle-orm";
import bcrypt from "bcrypt";
import { generateToken } from "../../utils/Auth";
import { OAuth2Client } from "google-auth-library";
import { googleClientIds } from "../../constants/api.constants";
import { sendEmail } from "../../utils/email";
const client = new OAuth2Client();

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

export const register = async (email: string, password: string, name: string) => {

  const existingUser = await db
    .select()
    .from(users)
    .where(eq(users.email, email));

  if (existingUser.length > 0) {
    throw new BadRequest('User with this email already exists');
  }

  const hashedPassword = await bcrypt.hash(password, 10);
  const userId = crypto.randomUUID();

  await db.insert(users).values({
    id: userId,
    email,
    password: hashedPassword,
    name,
    age: 0 // Provide a default age since it's required by the schema
  });

  const token = generateToken({
    id: userId,
    name,
    email,
  });

  return { 
    user: {
        id: userId,
        name,
        email
    }, 
    token 
  };
};


export const forgetPassword = async (email: string) => {
  const user = await db.query.users.findFirst({
    where: eq(users.email, email),
  });

  if (!user) {
    throw new BadRequest("User not found");
  }

  const code = Math.floor(100000 + Math.random() * 900000).toString(); // 6 digit code
  const expires = new Date();
  expires.setMinutes(expires.getMinutes() + 15); // 15 minutes expiration

  await db.update(users)
    .set({ resetPasswordCode: code, resetPasswordExpires: expires })
    .where(eq(users.id, user.id));

    await sendEmail(
    user.email,
    "Password Reset Code",
    `Your password reset code is: ${code}. It will expire in 15 minutes.`
  );

  return { message: "Password reset code sent to your email" };
};

export const verifyResetPasswordCode = async (code: string) => {
  const user = await db.query.users.findFirst({
    where: eq(users.resetPasswordCode, code),
  });

  if (!user) {
    throw new BadRequest("Invalid code");
  }

  if (user.resetPasswordExpires && new Date() > user.resetPasswordExpires) {
    throw new BadRequest("Code has expired");
  }

  return { valid: true };
};

export const resetPassword = async (token: string, newPassword: string) => {
  const user = await db.query.users.findFirst({
    where: eq(users.resetPasswordCode, token),
  });

  if (!user) {
    throw new BadRequest("Invalid token");
  }

  if (user.resetPasswordExpires && new Date() > user.resetPasswordExpires) {
    throw new BadRequest("Token has expired");
  }

  const hashedPassword = await bcrypt.hash(newPassword, 10);

  await db.update(users)
    .set({
      password: hashedPassword,
      resetPasswordCode: null,
      resetPasswordExpires: null,
    })
    .where(eq(users.id, user.id));

  return { message: "Password reset successfully" };
};

export const loginWithGoogle = async (idToken: string) => {
  const ticket = await client.verifyIdToken({
    idToken,
    audience: googleClientIds,
  });

  const payload = ticket.getPayload();
  if (!payload || !payload.email || !payload.name) {
    throw new BadRequest("Invalid Google token payload");
  }

  const { email, name, sub: googleId, picture: avatar } = payload;

  let user = await db.query.users.findFirst({
    where: eq(users.email, email),
  });

  if (!user) {
    const userId = crypto.randomUUID();
    // Create new user if they don't exist
    await db.insert(users).values({
      id: userId,
      email,
      password: "", // Google users might not need a password
      name,
      googleId,
      avatar,
      age: 0,
    });

    user = await db.query.users.findFirst({
      where: eq(users.email, email),
    });
  } else if (!user.googleId) {
    // Link existing user to Google ID
    await db.update(users)
      .set({ googleId, avatar: user.avatar || avatar })
      .where(eq(users.email, email));
    
    // Refresh user object
    user = await db.query.users.findFirst({
      where: eq(users.email, email),
    });
  }

  if (!user) {
     throw new BadRequest("Failed to sign in with Google");
  }

  const token = generateToken({
    id: user.id,
    name: user.name,
    email: user.email,
  });

  return { user, token };
};