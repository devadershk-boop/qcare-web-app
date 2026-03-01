const { Pool } = require('pg');

const db = new Pool({
    connectionString: 'postgresql://postgres.kkhyyhqlsrsayainqgwj:YvDJrjQVRuHLoAVU@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres',
    ssl: { rejectUnauthorized: false }
});

async function run() {
    try {
        await db.query(`ALTER TABLE Doctors ADD COLUMN IF NOT EXISTS hospital_name VARCHAR(255);`);
        console.log("Doctors table updated with hospital_name column.");
    } catch (err) {
        console.error(err);
    } finally {
        db.end();
    }
}

run();
