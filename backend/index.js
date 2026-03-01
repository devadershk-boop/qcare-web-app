console.log('--- Starting Qcare Backend ---');
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 5000;

// Supabase Connection Configuration
const db = new Pool({
  connectionString: 'postgresql://postgres.kkhyyhqlsrsayainqgwj:YvDJrjQVRuHLoAVU@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres',
  ssl: {
    rejectUnauthorized: false
  }
});

console.log('Attempting to connect to Supabase...');

app.use(cors());
app.use(express.json());

// Test connection
db.query('SELECT 1')
  .then(() => console.log('✅ Connected to Supabase PostgreSQL'))
  .catch(err => console.error('❌ Database connection failed:', err.message));

// =======================
// DATA (Legacy removed)
// =======================


// =======================
// HELPER — normalize name
// =======================
function norm(name) {
  if (!name) return '';
  return name.toLowerCase()
    .replace(/\./g, '')       // Remove dots
    .replace(/^dr\s+/, '')   // Remove leading 'dr '
    .replace(/\s+/g, ' ')    // Normalize spaces
    .trim();
}

function formatDateToLocal(d) {
  if (!d) return null;
  const pad = n => n.toString().padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}

// =======================
app.get('/', (req, res) => {
  res.send('Qcare backend running');
});

// =======================
app.get('/doctors', async (req, res) => {
  try {
    const result = await db.query(`
      SELECT d.*, dept.department_name, d.hospital_name 
      FROM Doctors d 
      LEFT JOIN Departments dept ON d.department_id = dept.department_id
    `);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// =======================
// GET DOCTOR PROFILE
// =======================
app.get('/doctors/profile/:doctor', async (req, res) => {
  const d = norm(req.params.doctor);
  try {
    const result = await db.query(`
      SELECT d.*, dept.department_name, d.hospital_name 
      FROM Doctors d 
      LEFT JOIN Departments dept ON d.department_id = dept.department_id
      WHERE d.name ILIKE $1 OR d.name = $2
    `, [`%${d}%`, req.params.doctor]);

    if (result.rows.length === 0) return res.status(404).json({ error: 'Doctor not found' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'DB Error profile' });
  }
});

// =======================
// GET PATIENT PROFILE
// =======================
app.get('/patients/profile/:name', async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM Patients WHERE name = $1', [req.params.name]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Patient not found' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: 'DB Error patient profile' });
  }
});

// =======================
// ADMIN LOGIN
// =======================
app.post('/admins/login', async (req, res) => {
  const { username, hospital_name, password } = req.body;

  if (password !== '000000') {
    return res.status(401).json({ error: 'Invalid admin credentials' });
  }

  try {
    // Check if admin exists
    const result = await db.query('SELECT * FROM Admins WHERE username = $1', [username]);

    if (result.rows.length === 0) {
      // Auto-create the admin record
      const insertResult = await db.query(
        'INSERT INTO Admins (username, hospital_name) VALUES ($1, $2) RETURNING *',
        [username, hospital_name]
      );
      return res.status(201).json({ message: 'Admin authenticated and created', admin: insertResult.rows[0] });
    }

    // Admin exists, update hospital_name just in case it changed (optional, but good for keeping sync)
    await db.query('UPDATE Admins SET hospital_name = $2 WHERE username = $1', [username, hospital_name]);

    res.json({ message: 'Admin authenticated', admin: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error handling admin login' });
  }
});

// =======================
// CREATE DEPARTMENT
// =======================
app.post('/departments', async (req, res) => {
  const { name, avg_time_minutes, hospital_name } = req.body;
  try {
    await db.query(
      'INSERT INTO Departments (department_name) VALUES ($1) ON CONFLICT (department_name) DO NOTHING',
      [name]
    );

    // Also initialize or update wait time
    await db.query(
      'INSERT INTO DepartmentWaitTimes (department_name, avg_time_minutes, hospital_name) VALUES ($1, $2, $3) ON CONFLICT (department_name) DO UPDATE SET avg_time_minutes = EXCLUDED.avg_time_minutes',
      [name, avg_time_minutes || 2, hospital_name]
    );

    res.status(201).json({ message: 'Department and wait time initialized' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB Error creating department' });
  }
});

// =======================
app.post('/doctors', async (req, res) => {
  const { name, specialization, department, username, email, password, hospital_name } = req.body;

  try {
    // 1. Find or Create department
    let depts = await db.query('SELECT department_id FROM Departments WHERE department_name = $1', [department]);
    let dept_id;

    if (depts.rows.length === 0) {
      const insertDept = await db.query('INSERT INTO Departments (department_name) VALUES ($1) RETURNING department_id', [department]);
      dept_id = insertDept.rows[0].department_id;
      // Initialize wait time
      await db.query('INSERT INTO DepartmentWaitTimes (department_name, hospital_name) VALUES ($1, $2) ON CONFLICT DO NOTHING', [department, hospital_name]);
    } else {
      dept_id = depts.rows[0].department_id;
      // Update hospital name if not already set (optional depending on exact requirements)
      await db.query('UPDATE DepartmentWaitTimes SET hospital_name = $2 WHERE department_name = $1 AND hospital_name IS NULL', [department, hospital_name]);
    }

    // 2. Insert Doctor
    try {
      const result = await db.query(
        'INSERT INTO Doctors (name, specialization, department_id, email, username, hospital_name) VALUES ($1, $2, $3, $4, $5, $6) RETURNING doctor_id',
        [name, specialization, dept_id, email, username, hospital_name]
      );
      res.status(201).json({ id: result.rows[0].doctor_id, message: 'Doctor created successfully' });
    } catch (dbErr) {
      if (dbErr.code === '23505') { // Unique constraint violation
        let detail = 'Doctor already exists';
        if (dbErr.detail.includes('username')) detail = 'Username already exists';
        if (dbErr.detail.includes('email')) detail = 'Email already exists';
        return res.status(400).json({ error: 'Duplicate data', details: detail });
      }
      throw dbErr; // Rethrow other DB errors to be caught by outer catch
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// =======================
// UPDATE DOCTOR
// =======================
app.put('/doctors/:id', async (req, res) => {
  const id = parseInt(req.params.id);
  const { name, specialization, department, hospital_name } = req.body;

  try {
    // 1. Find or Create department
    let depts = await db.query('SELECT department_id FROM Departments WHERE department_name = $1', [department]);
    let dept_id;

    if (depts.rows.length === 0) {
      const insertDept = await db.query('INSERT INTO Departments (department_name) VALUES ($1) RETURNING department_id', [department]);
      dept_id = insertDept.rows[0].department_id;
      // Initialize wait time
      await db.query('INSERT INTO DepartmentWaitTimes (department_name, hospital_name) VALUES ($1, $2) ON CONFLICT DO NOTHING', [department, hospital_name]);
    } else {
      dept_id = depts.rows[0].department_id;
      // Update hospital name if not already set
      await db.query('UPDATE DepartmentWaitTimes SET hospital_name = $2 WHERE department_name = $1 AND hospital_name IS NULL', [department, hospital_name]);
    }

    await db.query(
      'UPDATE Doctors SET name = $1, specialization = $2, department_id = $3, hospital_name = $5 WHERE doctor_id = $4',
      [name, specialization, dept_id, id, hospital_name]
    );

    res.json({ message: 'Doctor updated' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// =======================
// DELETE DOCTOR
// =======================
app.delete('/doctors/:id', async (req, res) => {
  const id = parseInt(req.params.id);

  try {
    await db.query('DELETE FROM Doctors WHERE doctor_id = $1', [id]);
    res.json({ message: 'Doctor deleted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error', details: err.message });
  }
});

// =======================
// BOOK — DB VERSION
// =======================
app.post('/appointments', async (req, res) => {
  const { patientName, department, doctor, date } = req.body;
  const dNorm = norm(doctor);

  try {
    // 1. Find or create Patient
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

    // 2. Find Doctor ID (mapping name/department)
    const doctorRes = await db.query(
      'SELECT doctor_id FROM Doctors WHERE name ILIKE $1',
      [`%${doctor.replace(/^dr\.?\s+/i, '')}%`]
    );

    if (doctorRes.rows.length === 0) {
      return res.status(404).json({ error: 'Doctor not found' });
    }
    const doctorId = doctorRes.rows[0].doctor_id;

    // 3. Calculate unique appointment_id (global max + 1)
    const maxIdRes = await db.query('SELECT MAX(appointment_id) FROM Appointments');
    const appointmentId = (maxIdRes.rows[0].max || 0) + 1;

    // 4. Calculate Expected Time 
    const deptWaitRes = await db.query(
      'SELECT avg_time_minutes FROM DepartmentWaitTimes dwt JOIN Departments d ON dwt.department_name = d.department_name WHERE d.department_name = $1',
      [department]
    );
    const avgTime = deptWaitRes.rows.length > 0 ? deptWaitRes.rows[0].avg_time_minutes : 2;

    const now = new Date();
    let baseTime = new Date(`${date}T09:00:00`);

    // Dynamic Base Time: if booking today strictly after 9:00 AM, shift base time to now
    const todayStr = formatDateToLocal(now);
    if (date === todayStr && now > baseTime) {
      baseTime = now;
    }

    // Count existing for this doctor to calculate wait time offset
    const countRes = await db.query(
      'SELECT COUNT(*) FROM Appointments WHERE doctor_id = $1 AND appointment_date = $2',
      [doctorId, date]
    );
    const count = parseInt(countRes.rows[0].count);

    const expectedDateTime = new Date(baseTime.getTime() + (count * avgTime * 60000));

    const hours24 = expectedDateTime.getHours();
    const ampm = hours24 >= 12 ? 'PM' : 'AM';
    const hours12 = hours24 % 12 || 12;
    const mins = expectedDateTime.getMinutes().toString().padStart(2, '0');
    const expectedTimeStr = `${hours12}:${mins} ${ampm}`;

    // 5. Insert into Appointments
    await db.query(
      'INSERT INTO Appointments (appointment_id, patient_id, doctor_id, appointment_date, time_slot) VALUES ($1, $2, $3, $4, $5)',
      [appointmentId, patientId, doctorId, date, expectedTimeStr]
    );

    const tokenNumber = count + 1;

    // 6. Insert into Queue (use doctor-specific count as the token number)
    await db.query(
      'INSERT INTO Queue (appointment_id, token_number, status) VALUES ($1, $2, $3)',
      [appointmentId, tokenNumber, 'WAITING']
    );

    res.status(201).json({
      message: "Booked",
      token: tokenNumber, // Return the proper token number here
      id: appointmentId,
      expectedTime: expectedTimeStr
    });

  } catch (err) {
    console.error("Booking error details:", err);
    res.status(500).json({ error: 'Database error booking appointment', details: err.message });
  }
});

// =======================
app.get('/appointments', async (req, res) => {
  try {
    const result = await db.query(`
      SELECT a.*, p.name as "patientName", d.name as "doctor", d.hospital_name as "hospital", dep.department_name as "department", q.status, q.token_number, dwt.current_consultation_start
      FROM Appointments a
      JOIN Patients p ON a.patient_id = p.patient_id
      JOIN Doctors d ON a.doctor_id = d.doctor_id
      JOIN Departments dep ON d.department_id = dep.department_id
      LEFT JOIN Queue q ON a.appointment_id = q.appointment_id
      LEFT JOIN DepartmentWaitTimes dwt ON dep.department_name = dwt.department_name
    `);
    res.json(result.rows.map(r => ({
      id: r.appointment_id,
      patientName: r.patientName,
      doctor: r.doctor,
      department: r.department,
      date: formatDateToLocal(r.appointment_date),
      time: r.time_slot,
      token: r.token_number,
      status: r.status || 'WAITING',
      startedAt: r.current_consultation_start
    })));
  } catch (err) {
    res.status(500).json({ error: 'DB Error' });
  }
});

// =======================
app.get('/appointments/patient/:name', async (req, res) => {
  const name = req.params.name;
  try {
    const result = await db.query(`
      SELECT a.*, p.name as "patientName", d.name as "doctor", d.hospital_name as "hospital", dep.department_name as "department", q.status, q.token_number
      FROM Appointments a
      JOIN Patients p ON a.patient_id = p.patient_id
      JOIN Doctors d ON a.doctor_id = d.doctor_id
      JOIN Departments dep ON d.department_id = dep.department_id
      LEFT JOIN Queue q ON a.appointment_id = q.appointment_id
      WHERE p.name = $1
    `, [name]);
    res.json(result.rows.map(r => ({
      id: r.appointment_id,
      patientName: r.patientName,
      doctor: r.doctor,
      department: r.department,
      date: formatDateToLocal(r.appointment_date),
      time: r.time_slot,
      token: r.token_number,
      status: r.status || 'WAITING'
    })));
  } catch (err) {
    res.status(500).json({ error: 'DB Error' });
  }
});

// =======================
// DOCTOR QUEUE — active only
// =======================
app.get('/appointments/doctor/:doctor', async (req, res) => {
  const d = norm(req.params.doctor);
  const { date, filter } = req.query;

  try {
    let query = `
      SELECT a.*, p.name as "patientName", d.name as "doctor", dep.department_name as "department", q.status, q.token_number, dwt.current_consultation_start
      FROM Appointments a
      JOIN Patients p ON a.patient_id = p.patient_id
      JOIN Doctors d ON a.doctor_id = d.doctor_id
      JOIN Departments dep ON d.department_id = dep.department_id
      LEFT JOIN Queue q ON a.appointment_id = q.appointment_id
      LEFT JOIN DepartmentWaitTimes dwt ON dep.department_name = dwt.department_name
      WHERE (d.name ILIKE $1 OR d.name = $2) 
    `;
    let params = [`%${d}%`, req.params.doctor];

    if (filter !== 'ALL') {
      query += ` AND q.status NOT IN ('COMPLETED', 'NOT_ATTENDED')`;
    }

    if (date) {
      query += ` AND a.appointment_date = $3`;
      params.push(date);
    } else {
      query += ` AND a.appointment_date = CURRENT_DATE`;
    }

    query += ` ORDER BY a.appointment_id ASC`;

    const result = await db.query(query, params);

    res.json(result.rows.map(r => ({
      id: r.appointment_id,
      patientName: r.patientName,
      doctor: r.doctor,
      department: r.department,
      date: formatDateToLocal(r.appointment_date),
      time: r.time_slot,
      token: r.token_number,
      status: r.status || 'WAITING',
      startedAt: r.current_consultation_start
    })));
  } catch (err) {
    res.status(500).json({ error: 'DB Error' });
  }
});

// =======================
// GET DOCTOR STATUS — DB VERSION
// =======================
app.get('/doctors/status/:doctor', async (req, res) => {
  const d = norm(req.params.doctor);
  try {
    const result = await db.query('SELECT on_break FROM Doctors WHERE name ILIKE $1 OR name = $2', [`%${d}%`, req.params.doctor]);
    if (result.rows.length === 0) return res.json({ onBreak: false });
    res.json({ onBreak: result.rows[0].on_break });
  } catch (err) {
    res.status(500).json({ error: 'DB Error doctor status' });
  }
});

// =======================
// TOGGLE BREAK
// =======================
app.post('/doctors/status/:doctor/break', async (req, res) => {
  const d = norm(req.params.doctor);
  const { onBreak } = req.body;

  try {
    const result = await db.query('UPDATE Doctors SET on_break = $1 WHERE name ILIKE $2 OR name = $3 RETURNING on_break', [onBreak, `%${d}%`, req.params.doctor]);
    if (result.rows.length === 0) return res.status(404).json({ error: 'Doctor not found' });
    res.json({ onBreak: result.rows[0].on_break });
  } catch (err) {
    res.status(500).json({ error: 'DB Error toggle break' });
  }
});

// =======================
// GET DEPARTMENT WAIT TIMES
// =======================
app.get('/appointments/status/waittimes', async (req, res) => {
  try {
    const result = await db.query('SELECT department_name, avg_time_minutes, current_consultation_start, hospital_name FROM DepartmentWaitTimes');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'DB Error fetching wait times' });
  }
});

// =======================
// DOCTOR ALL APPOINTMENTS (with optional filters)
// =======================
app.get('/appointments/doctor/:doctor/all', async (req, res) => {
  const d = norm(req.params.doctor);
  const { year, month, date } = req.query;

  try {
    let query = `
      SELECT a.*, p.name as "patientName", d.name as "doctor", dep.department_name as "department", q.status, q.token_number
      FROM Appointments a
      JOIN Patients p ON a.patient_id = p.patient_id
      JOIN Doctors d ON a.doctor_id = d.doctor_id
      JOIN Departments dep ON d.department_id = dep.department_id
      LEFT JOIN Queue q ON a.appointment_id = q.appointment_id
      WHERE (d.name ILIKE $1 OR d.name = $2)
    `;
    let params = [`%${d}%`, req.params.doctor];

    if (date) {
      query += ` AND a.appointment_date = $3`;
      params.push(date);
    } else {
      if (year) {
        query += ` AND EXTRACT(YEAR FROM a.appointment_date) = $${params.length + 1}`;
        params.push(year);
      }
      if (month) {
        query += ` AND EXTRACT(MONTH FROM a.appointment_date) = $${params.length + 1}`;
        params.push(month);
      }
    }
    query += ` ORDER BY a.appointment_date DESC, a.appointment_id ASC`;

    const result = await db.query(query, params);
    res.json(result.rows.map(r => ({
      id: r.appointment_id,
      patientName: r.patientName,
      doctor: r.doctor,
      department: r.department,
      date: formatDateToLocal(r.appointment_date),
      time: r.time_slot,
      token: r.token_number,
      status: r.status || 'WAITING'
    })));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB Error history' });
  }
});


// =======================
// UPDATE STATUS
// =======================
app.patch('/appointments/:id/status', async (req, res) => {
  const id = parseInt(req.params.id);
  const { status } = req.body;

  try {
    const result = await db.query(
      'UPDATE Queue SET status = $1 WHERE appointment_id = $2 RETURNING *',
      [status, id]
    );

    if (result.rows.length === 0) {
      // Fallback: If no Queue entry exists yet, create one
      await db.query(
        'INSERT INTO Queue (appointment_id, token_number, status) VALUES ($1, $1, $2)',
        [id, status]
      );
    }

    if (status === 'IN_PROGRESS') {
      // Update department consultation start time
      await db.query(`
        UPDATE DepartmentWaitTimes dwt
        SET current_consultation_start = CURRENT_TIMESTAMP
        FROM Departments dep, Doctors d, Appointments a
        WHERE dwt.department_name = dep.department_name
        AND d.department_id = dep.department_id
        AND a.doctor_id = d.doctor_id
        AND a.appointment_id = $1
      `, [id]);
    } else if (status === 'COMPLETED') {
      // Recalculate rolling average
      await db.query(`
          UPDATE DepartmentWaitTimes dwt
          SET 
             avg_time_minutes = GREATEST(1, ROUND((avg_time_minutes * 3.0 + EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - current_consultation_start))/60.0) / 4.0)),
             current_consultation_start = NULL
          FROM Departments dep, Doctors d, Appointments a
          WHERE dwt.department_name = dep.department_name
          AND d.department_id = dep.department_id
          AND a.doctor_id = d.doctor_id
          AND a.appointment_id = $1
          AND dwt.current_consultation_start IS NOT NULL
        `, [id]);
    }

    res.json({ message: 'Status updated', id, status });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB Error updating status' });
  }
});

// =======================
// CALL NEXT — DB VERSION
// =======================
app.post('/appointments/call-next/:doctor', async (req, res) => {
  const d = norm(req.params.doctor);
  const { date } = req.query;

  try {
    // 1. Get Doctor ID
    const drRes = await db.query('SELECT doctor_id FROM Doctors WHERE name ILIKE $1 OR name = $2', [`%${d}%`, req.params.doctor]);
    if (drRes.rows.length === 0) return res.status(404).json({ error: 'Doctor not found' });
    const doctorId = drRes.rows[0].doctor_id;

    // 1.5 Calculate and apply rolling average from the previously running session
    await db.query(`
      UPDATE DepartmentWaitTimes dwt
      SET 
         avg_time_minutes = GREATEST(1, ROUND((avg_time_minutes * 3.0 + EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - current_consultation_start))/60.0) / 4.0))
      FROM Departments dep, Doctors d
      WHERE dwt.department_name = dep.department_name
      AND d.department_id = dep.department_id
      AND d.doctor_id = $1
      AND dwt.current_consultation_start IS NOT NULL
    `, [doctorId]);

    // 2. Find current IN_PROGRESS for this doctor and set it to COMPLETED
    let updateQuery = `
      UPDATE Queue q
      SET status = 'COMPLETED'
      FROM Appointments a
      WHERE q.appointment_id = a.appointment_id
      AND a.doctor_id = $1
      AND q.status = 'IN_PROGRESS'
    `;
    let qParams = [doctorId];
    if (date) {
      updateQuery += ` AND a.appointment_date = $2`;
      qParams.push(date);
    }
    await db.query(updateQuery, qParams);

    // 3. Find next WAITING patient 
    let nextQuery = `
      SELECT a.*, p.name as "patientName", q.token_number
      FROM Appointments a
      JOIN Patients p ON a.patient_id = p.patient_id
      JOIN Queue q ON a.appointment_id = q.appointment_id
      WHERE a.doctor_id = $1 AND q.status = 'WAITING'
    `;
    let nextParams = [doctorId];

    if (date) {
      nextQuery += ` AND a.appointment_date = $2`;
      nextParams.push(date);
    } else {
      nextQuery += ` AND a.appointment_date = CURRENT_DATE`;
    }

    nextQuery += ` ORDER BY a.appointment_id ASC LIMIT 1`;

    const nextRes = await db.query(nextQuery, nextParams);

    if (nextRes.rows.length === 0) {
      return res.json({ message: "No more waiting patients today", next: null });
    }

    const next = nextRes.rows[0];

    // 4. Update next patient to IN_PROGRESS
    await db.query(
      'UPDATE Queue SET status = $1 WHERE appointment_id = $2',
      ['IN_PROGRESS', next.appointment_id]
    );

    // Update department consultation start time
    await db.query(`
      UPDATE DepartmentWaitTimes dwt
      SET current_consultation_start = CURRENT_TIMESTAMP
      FROM Departments dep, Doctors d
      WHERE dwt.department_name = dep.department_name
      AND d.department_id = dep.department_id
      AND d.doctor_id = $1
    `, [doctorId]);

    res.json({
      message: "Call next successful",
      next: {
        id: next.appointment_id,
        patientName: next.patientName,
        token: next.token_number
      }
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'DB Error call-next' });
  }
});

// =======================
app.listen(port, () => {
  console.log(`🚀 QCare API server running on port ${port}`);
});
