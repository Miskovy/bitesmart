import { getRedisClient, isRedisReady } from "../../utils/redis";

export interface OTPStore {
    set(code: string, email: string, ttlSeconds: number): Promise<void>;
    get(code: string): Promise<string | null>;
    delete(code: string): Promise<void>;
}

class MemoryOTPStore implements OTPStore {
    private store = new Map<string, { email: string; expiresAt: number }>();

    async set(code: string, email: string, ttlSeconds: number): Promise<void> {
        const expiresAt = Date.now() + ttlSeconds * 1000;
        this.store.set(code, { email, expiresAt });
    }

    async get(code: string): Promise<string | null> {
        const entry = this.store.get(code);
        if (!entry) return null;
        if (Date.now() > entry.expiresAt) {
            this.store.delete(code);
            return null;
        }
        return entry.email;
    }

    async delete(code: string): Promise<void> {
        this.store.delete(code);
    }
}

class RedisOTPStore implements OTPStore {
    async set(code: string, email: string, ttlSeconds: number): Promise<void> {
        const client = getRedisClient();
        if (client) {
            await client.set(`otp:code:${code}`, email, "EX", ttlSeconds);
        }
    }

    async get(code: string): Promise<string | null> {
        const client = getRedisClient();
        if (client) {
            return await client.get(`otp:code:${code}`);
        }
        return null;
    }

    async delete(code: string): Promise<void> {
        const client = getRedisClient();
        if (client) {
            await client.del(`otp:code:${code}`);
        }
    }
}

class HybridOTPStore implements OTPStore {
    private memoryStore = new MemoryOTPStore();
    private redisStore = new RedisOTPStore();

    async set(code: string, email: string, ttlSeconds: number): Promise<void> {
        if (isRedisReady()) {
            try {
                await this.redisStore.set(code, email, ttlSeconds);
                return;
            } catch (err: any) {
                console.warn("Failed to write OTP to Redis, falling back to memory store:", err.message);
            }
        }
        await this.memoryStore.set(code, email, ttlSeconds);
    }

    async get(code: string): Promise<string | null> {
        if (isRedisReady()) {
            try {
                const email = await this.redisStore.get(code);
                if (email) return email;
            } catch (err: any) {
                console.warn("Failed to get OTP from Redis, falling back to memory store:", err.message);
            }
        }
        return await this.memoryStore.get(code);
    }

    async delete(code: string): Promise<void> {
        if (isRedisReady()) {
            try {
                await this.redisStore.delete(code);
                return;
            } catch (err: any) {
                console.warn("Failed to delete OTP from Redis, falling back to memory store:", err.message);
            }
        }
        await this.memoryStore.delete(code);
    }
}

export const otpStore = new HybridOTPStore();
