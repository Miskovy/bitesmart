import Redis from "ioredis";

let redisClient: Redis | null = null;
let isRedisEnabled = false;

const redisUrl = process.env.REDIS_URL;
const redisHost = process.env.REDIS_HOST;
const redisPort = parseInt(process.env.REDIS_PORT || "6379", 10);

if (redisUrl || redisHost) {
    try {
        if (redisUrl) {
            redisClient = new Redis(redisUrl, {
                maxRetriesPerRequest: 1,
                connectTimeout: 3000,
            });
        } else {
            redisClient = new Redis({
                host: redisHost,
                port: redisPort,
                maxRetriesPerRequest: 1,
                connectTimeout: 3000,
            });
        }

        redisClient.on("connect", () => {
            console.log("Successfully connected to Redis.");
            isRedisEnabled = true;
        });

        redisClient.on("error", (err: any) => {
            console.warn("Redis connection error. Falling back to in-memory store for OTPs:", err.message);
            isRedisEnabled = false;
        });
    } catch (error: any) {
        console.warn("Failed to initialize Redis client. Falling back to in-memory store:", error.message);
    }
} else {
    console.log("Redis environment variables not configured. Using in-memory store for OTPs.");
}

export const getRedisClient = () => redisClient;
export const isRedisReady = () => isRedisEnabled && redisClient !== null;
