import mysql from 'mysql2/promise';
import 'dotenv/config';

const config = {
    host    : process.env.DATABASE_HOST     || 'localhost',
    user    : process.env.DATABASE_USER     || 'root',
    password: process.env.DATABASE_PASSWORD || '',
    database: process.env.DATABASE_NAME     || 'bitesmart',
};

const createDatabase = async () => {
    const connection = await mysql.createConnection({
        host    : config.host,
        user    : config.user,
        password: config.password,
    });

    try {
        console.log(`Creating database '${config.database}'...`);
        await connection.query(`CREATE DATABASE IF NOT EXISTS \`${config.database}\``);
        console.log(`Database '${config.database}' created successfully!\n`);
        console.log('Next steps:');
        console.log('  1. Run: npm run migrate-db');
        console.log('  2. Run: npm run dev');
    } catch (error) {
        console.error('Failed to create database:', error);
        process.exit(1);
    } finally {
        await connection.end();
    }
};

createDatabase();