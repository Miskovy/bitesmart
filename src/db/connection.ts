import 'dotenv/config';
import mysql from 'mysql2/promise';
import { drizzle } from 'drizzle-orm/mysql2';
import * as schema from '../db/schema';

const pool = mysql.createPool({
    uri                : process.env.DATABASE_URL || 'mysql://user:password@localhost:3306/bitesmart',
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