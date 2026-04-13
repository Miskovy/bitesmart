import 'dotenv/config';
import mysql from 'mysql2/promise';

export async function connectToDatabase() {
  const url = process.env.DATABASE_URL || 'mysql://user:password@localhost:3306/bitesmart';
  try {
    const connection = await mysql.createConnection(url);
    console.log('Connected to database');
    return connection;
  } catch (error) {
    console.error('Error connecting to database:', error);
    process.exit(1);
  }
}