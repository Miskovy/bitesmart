import 'dotenv/config';
import mysql from 'mysql2/promise';

async function createDatabase() {
  const url = process.env.DATABASE_URL || 'mysql://user:password@localhost:3306';
  
  // Extract base URL without the database name to connect simply to the server
  const dbNameMatch = url.match(/\/([a-zA-Z0-9_-]+)(?:\?.*)?$/);
  const dbName = dbNameMatch ? dbNameMatch[1] : 'bitesmart';
  const baseUrl = url.replace(`/${dbName}`, '');

  console.log(`Connecting to ${baseUrl} to create database ${dbName}...`);
  try {
    const connection = await mysql.createConnection(baseUrl);
    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\`;`);
    console.log(`Database '${dbName}' created or already exists.`);
    await connection.end();
  } catch (error) {
    console.error('Error creating database:', error);
    process.exit(1);
  }
}

createDatabase();

