import { db } from "../../db/connection";
import { BadRequest } from "../../errors";
import { users } from "../../models/user";
import { eq } from "drizzle-orm";
import bcrypt from "bcrypt";
import { generateToken } from "../../utils/Auth";
import { OAuth2Client } from "google-auth-library";
import { googleClientIds } from "../../constants/api.constants";
import { sendEmail } from "../../utils/email";
import { otpStore } from "./otpStore";
import { getForgotEmailTemplate } from "../../utils/emailTemplate";
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
    id: user.id,
    name: user.name,
    email: user.email,
  });

  //! Created by Antigravity: Strip password hash from login response to prevent credential leak
  const { password: _pw, ...safeUser } = user;
  return { user: safeUser, token };
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
    return { message: "If an account exists with this email, a password reset code has been sent" };
  }
  const randomBytes = new Uint32Array(1);
  crypto.getRandomValues(randomBytes);
  const code = (100000 + (randomBytes[0] % 900000)).toString();
  await otpStore.set(code, user.email, 900);

  const textBody = `Your password reset code is: ${code}. It will expire in 15 minutes.`;
  const htmlBody = getForgotEmailTemplate(code);

  await sendEmail(
    user.email,
    "Password Reset Code",
    textBody,
    htmlBody
  );

  return { message: "If an account exists with this email, a password reset code has been sent" };
};

export const verifyResetPasswordCode = async (code: string) => {
  const email = await otpStore.get(code);

  if (!email) {
    throw new BadRequest("Invalid or expired code");
  }

  return { valid: true };
};

export const resetPassword = async (token: string, newPassword: string) => {
  const email = await otpStore.get(token);

  if (!email) {
    throw new BadRequest("Invalid or expired reset token");
  }

  const user = await db.query.users.findFirst({
    where: eq(users.email, email),
  });

  if (!user) {
    throw new BadRequest("User not found");
  }

  const hashedPassword = await bcrypt.hash(newPassword, 10);

  await db.update(users)
    .set({
      password: hashedPassword,
    })
    .where(eq(users.id, user.id));

  // Delete the OTP code from the store once used
  await otpStore.delete(token);

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

  const { password: _pw, ...safeGoogleUser } = user;
  return { user: safeGoogleUser, token };
};