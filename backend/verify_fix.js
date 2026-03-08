const { Pool } = require('pg');

const db = new Pool({
    connectionString: 'postgresql://postgres.kkhyyhqlsrsayainqgwj:YvDJrjQVRuHLoAVU@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres',
    ssl: {
        rejectUnauthorized: false
    }
});

async function verifyFix() {
    try {
        const result = await db.query('SELECT department_name, avg_time_minutes FROM DepartmentWaitTimes');
        console.log('--- Current Department Wait Times ---');
        result.rows.forEach(row => {
            console.log(`${row.department_name}: ${row.avg_time_minutes} mins`);
        });

        const allTwo = result.rows.every(row => row.avg_time_minutes === 2);
        if (allTwo) {
            console.log('\n✅ All departments are correctly set to 2 minutes.');
        } else {
            console.log('\n❌ Some departments are NOT set to 2 minutes.');
        }
        process.exit(0);
    } catch (err) {
        console.error('❌ Error verifying values:', err.message);
        process.exit(1);
    }
}

verifyFix();
