const { Pool } = require('pg');

const db = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'hospital_db',
    password: 'password',
    port: 5432,
});

async function run() {
    try {
        const res = await db.query('SELECT 1');
        console.log("DB connection successful");

        // Test the insert specifically
        const patientName = "TestNode123";
        const date = "2026-03-01";
        let patientRes = await db.query('SELECT patient_id FROM Patients WHERE name = $1', [patientName]);
        let patientId;
        if (patientRes.rows.length === 0) {
            const newPatient = await db.query(
                'INSERT INTO Patients (name) VALUES ($1) RETURNING patient_id',
                [patientName]
            );
            patientId = newPatient.rows[0].patient_id;
        } else {
            patientId = patientRes.rows[0].patient_id;
        }
        console.log("Patient Insert/Select Success: ID", patientId);

        // Doctor
        const doctorId = 1; // Assuming Dr John
        const appointmentId = 999;
        const expectedTimeStr = "10:00 AM";

        await db.query(
            'INSERT INTO Appointments (appointment_id, patient_id, doctor_id, for_date, time_slot) VALUES ($1, $2, $3, $4, $5)',
            [appointmentId, patientId, doctorId, date, expectedTimeStr]
        );
        console.log("Appointment Insert Success");

        await db.query(
            'INSERT INTO Queue (appointment_id, token_number, status) VALUES ($1, $2, $3)',
            [appointmentId, 123, 'WAITING']
        );
        console.log("Queue Insert Success");

        await db.query('DELETE FROM Queue WHERE appointment_id = 999');
        await db.query('DELETE FROM Appointments WHERE appointment_id = 999');

    } catch (err) {
        console.error("DB Error:", err.message);
    } finally {
        db.end();
    }
}

run();
