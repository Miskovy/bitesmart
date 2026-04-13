import jwt, { JsonWebTokenError, TokenExpiredError, SignOptions } from 'jsonwebtoken';
import { UnauthorizedError } from '../errors';
import { TokenPayload } from '../types/custom';
import 'dotenv/config';

const JWT_SECRET = process.env.JWT_SECRET as string;

const TOKEN_EXPIRY: SignOptions['expiresIn'] = '7d';

interface GenerateTokenInput {
    id: string;
    name: string;
    email: string;
}

// Generate JWT token
export const generateToken = (data: GenerateTokenInput): string => {
    const payload: TokenPayload = {
        id: data.id,
        name: data.name,
    };

    return jwt.sign(payload, JWT_SECRET, { expiresIn: TOKEN_EXPIRY });
};

// Verify JWT token
export const verifyToken = (token: string): TokenPayload => {
    try {
        return jwt.verify(token, JWT_SECRET) as TokenPayload;
    } catch (error) {
        if (error instanceof TokenExpiredError) {
            throw new UnauthorizedError('Token expired');
        }
        if (error instanceof JsonWebTokenError) {
            throw new UnauthorizedError('Invalid token');
        }
        throw new UnauthorizedError('Error while verifying token');
    }
};

// Extract token from request headers
export const extractTokenFromHeader = (
    authHeader: string | undefined
): string => {
    if (!authHeader) {
        throw new UnauthorizedError('No token provided');
    }

    const [bearer, token] = authHeader.split(' ');

    if (bearer !== 'Bearer' || !token) {
        throw new UnauthorizedError('Invalid token format');
    }

    return token;
};

// Refresh token
export const refreshToken = (oldToken: string): string => {
    const decoded = verifyToken(oldToken);

    const payload: TokenPayload = {
        id: decoded.id,
        name: decoded.name,
    };

    return jwt.sign(payload, JWT_SECRET, { expiresIn: TOKEN_EXPIRY });
};

// Decode token without verification
export const decodeToken = (token: string): TokenPayload | null => {
    try {
        return jwt.decode(token) as TokenPayload | null;
    } catch {
        return null;
    }
};

// Check if token is expiring soon
export const isTokenExpiringSoon = (
    token: string,
    thresholdHours: number = 24
): boolean => {
    try {
        const decoded = jwt.decode(token) as TokenPayload & { exp?: number };

        if (!decoded?.exp) return false;

        const expirationTime = decoded.exp * 1000; // Convert to milliseconds
        const currentTime = Date.now();
        const thresholdMs = thresholdHours * 60 * 60 * 1000;

        return expirationTime - currentTime < thresholdMs;
    } catch {
        return false;
    }
};


// Get token expiration time
export const getTokenExpiration = (token: string): Date | null => {
    try {
        const decoded = jwt.decode(token) as TokenPayload & { exp?: number };

        if (!decoded?.exp) return null;

        return new Date(decoded.exp * 1000);
    } catch {
        return null;
    }
};