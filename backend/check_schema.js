const { Pool } = require('pg');
const db = new Pool({
    connectionString: 'postgresql://postgres.kkhyyhqlsrsayainqgwj:YvDJrjQVRuHLoAVU@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres',
    ssl: { rejectUnauthorized: false }
});

async function run() {
    try {
        const res = await db.query("SELECT column_name FROM information_schema.columns WHERE table_name='appointments';");
        console.log('Appointments columns:', res.rows.map(r => r.column_name));
        const res2 = await db.query("SELECT column_name FROM information_schema.columns WHERE table_name='queue';");
        console.log('Queue columns:', res2.rows.map(r => r.column_name));
    } catch (err) {
        console.error(err);
    } finally {
        db.end();
    }
}
run();
