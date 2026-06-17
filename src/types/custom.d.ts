export type Role = "admin" | "user";

export interface TokenPayload {
  id: string;
  name: string;
  email: string;
  role?: Role;
}

type AppUser = TokenPayload;

declare global {
  namespace Express {
    interface Request {
      user?: AppUser;
      admin?: AppUser;
    }
  }
}

export interface ApiResponse<T = any> {
  success: boolean;
  message: string;
  data?: T;
  error?: {
    code: number;
    message: string;
    details?: any;
  };
}
