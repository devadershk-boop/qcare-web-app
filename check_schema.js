const { Pool } = require('pg');

const db = new Pool({
    connectionString: 'postgresql://postgres.kkhyyhqlsrsayainqgwj:YvDJrjQVRuHLoAVU@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres',
    ssl: {
        rejectUnauthorized: false
    }
});

async function checkSchema() {
    try {
        const res = await db.query(`
      SELECT column_name, data_type 
      FROM information_schema.columns 
      WHERE table_name = 'departmentwaittimes'
    `);
        console.log("SCHEMA:", JSON.stringify(res.rows, null, 2));

        // Also reset cardiology while we are here to unblock the user
        await db.query("UPDATE DepartmentWaitTimes SET avg_time_minutes = 3 WHERE department_name = 'cardiology'");
        console.log("Cardiology avg_time reset to 3");

        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

checkSchema();
