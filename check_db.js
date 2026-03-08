const { Pool } = require('pg');

const db = new Pool({
    connectionString: 'postgresql://postgres.kkhyyhqlsrsayainqgwj:YvDJrjQVRuHLoAVU@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres',
    ssl: {
        rejectUnauthorized: false
    }
});

async function dumpWaitTimes() {
    try {
        const res = await db.query('SELECT * FROM DepartmentWaitTimes');
        console.log("WAIT TIMES", JSON.stringify(res.rows, null, 2));

        // Also check Appointments to see count of today
        const countRes = await db.query("SELECT COUNT(*) FROM Appointments WHERE appointment_date = '2026-03-03'");
        console.log("APPT COUNT TODAY:", countRes.rows[0].count);

        // ALSO check doctors wait times specifically
        const deptRes = await db.query("SELECT department_name FROM Departments");
        console.log("DEPARTMENTS:", JSON.stringify(deptRes.rows, null, 2));

        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
}

dumpWaitTimes();
