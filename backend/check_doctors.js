const { Pool } = require('pg');
const db = new Pool({
    connectionString: 'postgresql://postgres.kkhyyhqlsrsayainqgwj:YvDJrjQVRuHLoAVU@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres',
    ssl: { rejectUnauthorized: false }
});

db.query('SELECT doctor_id, name FROM Doctors').then(res => {
    console.log(res.rows);
    process.exit(0);
}).catch(console.error);
