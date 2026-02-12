const express = require('express');
const cors = require('cors');

const app = express();
const PORT = 5000;

// =======================
// MIDDLEWARE
// =======================
app.use(cors());
app.use(express.json());

// =======================
// IN-MEMORY STORAGE (TEMP)
// =======================
let doctors = [
  { id: 1, name: 'Dr. Arun', department: 'Cardiology' },
  { id: 2, name: 'Dr. Meera', department: 'Neurology' },
];

let appointments = [];
let currentToken = 1;

// =======================
// TEST ROUTE
// =======================
app.get('/', (req, res) => {
  res.send('Qcare Backend is running 🚀');
});

// =======================
// GET ALL DOCTORS
// =======================
app.get('/doctors', (req, res) => {
  res.json(doctors);
});

// =======================
// POST: BOOK APPOINTMENT
// =======================
app.post('/appointments', (req, res) => {
  const { patientName, department, doctor, date, time } = req.body;

  // Validation
  if (!patientName || !department || !doctor || !date || !time) {
    return res.status(400).json({
      error: 'All fields are required',
    });
  }

  // Create appointment with token
  const appointment = {
    id: appointments.length + 1,
    patientName,
    department,
    doctor,
    date,
    time,
    token: currentToken,
    status: 'WAITING',
  };

  appointments.push(appointment);
  currentToken++;

  res.status(201).json({
    message: 'Appointment booked successfully',
    token: appointment.token,
    status: appointment.status,
  });
});

// =======================
// GET QUEUE (FOR DOCTOR)
// =======================
app.get('/appointments', (req, res) => {
  res.json(appointments);
});

// =======================
// START SERVER
// =======================
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
