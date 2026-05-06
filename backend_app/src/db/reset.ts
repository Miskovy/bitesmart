import { sql } from 'drizzle-orm';
import { db } from './connection';

const resetDb = async () => {
    try {
        console.log('Resetting Database...');

        await db.execute(sql`SET FOREIGN_KEY_CHECKS = 0;`);
        
        // Fetch all tables from the database
        // Use raw query to bypass typing constraints mostly
        const [tables]: any = await db.execute(sql`
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = DATABASE();
        `);

        if (tables.length > 0) {
            for (const table of tables) {
                const tableName = table.TABLE_NAME || table.table_name;
                console.log(`Dropping table: ${tableName}`);
                await db.execute(sql.raw(`DROP TABLE IF EXISTS \`${tableName}\`;`));
            }
            console.log('✅ All tables dropped successfully!');
        } else {
            console.log('No tables found to drop.');
        }

        await db.execute(sql`SET FOREIGN_KEY_CHECKS = 1;`);
        console.log('✅ Database reset finished successfully!');

    } catch (e) {
        console.error('❌ Failed to reset database:', e);
    } finally {
        process.exit(0);
    }
};

resetDb();
