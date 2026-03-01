const { Pool } = require('pg');
const db = new Pool({
    connectionString: 'postgresql://postgres.kkhyyhqlsrsayainqgwj:YvDJrjQVRuHLoAVU@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres',
    ssl: { rejectUnauthorized: false }
});

async function run() {
    try {
        const res = await db.query(`
      INSERT INTO Appointments (appointment_id, patient_id, doctor_id, for_date, time_slot) 
      VALUES (999999, 1, 1, '2026-03-01', '10:00 AM')
    `);
        console.log('Success:', res.rowCount);
    } catch (err) {
        console.error('DB Error:', err.message);
    } finally {
        db.end();
    }
}
run();
