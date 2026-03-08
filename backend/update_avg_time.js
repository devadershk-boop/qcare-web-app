const { Pool } = require('pg');

const db = new Pool({
    connectionString: 'postgresql://postgres.kkhyyhqlsrsayainqgwj:YvDJrjQVRuHLoAVU@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres',
    ssl: {
        rejectUnauthorized: false
    }
});

async function updateAvgTimes() {
    try {
        console.log('Attempting to update avg_time_minutes to 2 for all departments...');
        const result = await db.query('UPDATE DepartmentWaitTimes SET avg_time_minutes = 2');
        console.log(`✅ Successfully updated ${result.rowCount} departments.`);
        process.exit(0);
    } catch (err) {
        console.error('❌ Error updating avg_time_minutes:', err.message);
        process.exit(1);
    }
}

updateAvgTimes();
