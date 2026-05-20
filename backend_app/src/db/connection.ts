import 'dotenv/config';
import mysql from 'mysql2/promise';
import { drizzle } from 'drizzle-orm/mysql2';
import * as schema from '../db/schema';

//! Created by Antigravity: Fail fast if DATABASE_URL is not configured
const databaseUrl = process.env.DATABASE_URL;
if (!databaseUrl) {
    throw new Error("FATAL: DATABASE_URL environment variable is not set. Server cannot start.");
}

const pool = mysql.createPool({
    uri                : databaseUrl,
    waitForConnections : true,
    connectionLimit    : 10,
    queueLimit         : 0,
    idleTimeout        : 60000,
    enableKeepAlive    : true,
});

export const db = drizzle(pool, { schema, mode: 'default' });

export const connectToDatabase = async () => {
    try {
        const connection = await pool.getConnection();
        console.log('Database connected successfully');
        connection.release();
    } catch (error) {
        console.error('Database connection failed:', error);
        process.exit(1);
    }
};

export default pool;