const { Pool } = require('pg');

const db = new Pool({
    connectionString: 'postgresql://postgres.kkhyyhqlsrsayainqgwj:YvDJrjQVRuHLoAVU@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres',
    ssl: {
        rejectUnauthorized: false
    }
});

async function run() {
    try {
        await db.query(`
      CREATE TABLE IF NOT EXISTS Admins (
          admin_id SERIAL PRIMARY KEY,
          username VARCHAR(255) UNIQUE NOT NULL,
          role VARCHAR(50) DEFAULT 'admin',
          hospital_name VARCHAR(255),
          password VARCHAR(255) DEFAULT '000000'
      );
    `);
        console.log("Admins table ensured.");
    } catch (err) {
        console.error(err);
    } finally {
        db.end();
    }
}

run();
