export type Role = 'admin' | 'user';

export interface TokenPayload {
    id: string;
    name: string;
}

//! Created by Antigravity: Define AppUser to match TokenPayload for proper Express Request typing
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