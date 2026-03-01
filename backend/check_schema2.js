const { Pool } = require('pg');
const pool = new Pool({
    connectionString: 'postgresql://postgres.kkhyyhqlsrsayainqgwj:YvDJrjQVRuHLoAVU@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres',
    ssl: { rejectUnauthorized: false }
});
pool.query("SELECT column_name FROM information_schema.columns WHERE table_name='appointments'")
    .then(r => {
        console.log(r.rows);
        process.exit(0);
    })
    .catch(e => {
        console.error(e.message);
        process.exit(1);
    });
