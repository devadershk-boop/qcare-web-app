const { Pool } = require('pg');

const db = new Pool({
    connectionString: 'postgresql://postgres.kkhyyhqlsrsayainqgwj:YvDJrjQVRuHLoAVU@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres',
    ssl: {
        rejectUnauthorized: false
    }
});

async function checkTime() {
    try {
        const res = await db.query('SELECT NOW() as db_now, CURRENT_TIMESTAMP as db_ts, LOCALTIMESTAMP as db_local');
        console.log("DB TIME:", JSON.stringify(res.rows[0], null, 2));

        const cardRes = await db.query("SELECT * FROM DepartmentWaitTimes WHERE department_name = 'cardiology'");
        console.log("CARDIOLOGY ROW:", JSON.stringify(cardRes.rows[0], null, 2));

        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

checkTime();
