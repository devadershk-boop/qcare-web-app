-- Create Departments Table
CREATE TABLE IF NOT EXISTS Departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

-- Create Doctors Table
CREATE TABLE IF NOT EXISTS Doctors (
    doctor_id SERIAL PRIMARY KEY,
    department_id INT,
    name VARCHAR(255) NOT NULL,
    specialization VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    username VARCHAR(255) UNIQUE,
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

-- Create Patients Table
CREATE TABLE IF NOT EXISTS Patients (
    patient_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    dob DATE,
    contact TEXT,
    email TEXT UNIQUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create Appointments Table
CREATE TABLE IF NOT EXISTS Appointments (
    appointment_id INT PRIMARY KEY, -- Using as Token No as requested
    patient_id INT,
    doctor_id INT,
   
    appointment_date DATE NOT NULL,

    time_slot VARCHAR(20),
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

-- Create Queue Table for status tracking
CREATE TABLE IF NOT EXISTS Queue (
    queue_id SERIAL PRIMARY KEY,
    appointment_id INT,
    token_number INT,
    status VARCHAR(20) DEFAULT 'WAITING',
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id)
);

-- DepartmentWaitTimes Table
CREATE TABLE IF NOT EXISTS DepartmentWaitTimes (
    id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) UNIQUE REFERENCES Departments(department_name),
    avg_time_minutes INT DEFAULT 2,
    current_consultation_start TIMESTAMPTZ
);

-- Update Doctors Table (for already existing databases)
ALTER TABLE Doctors ADD COLUMN IF NOT EXISTS email VARCHAR(255) UNIQUE;
ALTER TABLE Doctors ADD COLUMN IF NOT EXISTS username VARCHAR(255) UNIQUE;
ALTER TABLE Doctors ADD COLUMN IF NOT EXISTS hospital_name VARCHAR(255);
ALTER TABLE Doctors ADD COLUMN IF NOT EXISTS on_break BOOLEAN DEFAULT false;

-- Update Patients Table (for already existing databases)
ALTER TABLE Patients ADD COLUMN IF NOT EXISTS dob DATE;
ALTER TABLE Patients ADD COLUMN IF NOT EXISTS contact TEXT;
ALTER TABLE Patients ADD COLUMN IF NOT EXISTS email TEXT UNIQUE;
ALTER TABLE Patients ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;

-- Update Appointments Table (for already existing databases)
ALTER TABLE Appointments ADD COLUMN IF NOT EXISTS time_slot VARCHAR(20);
ALTER TABLE Appointments ADD COLUMN IF NOT EXISTS appointment_date DATE;

-- Rename existing columns if they exist (for databases created before these changes)
DO $$
BEGIN
  IF EXISTS(SELECT * FROM information_schema.columns WHERE table_name='appointments' and column_name='created_at') THEN
      ALTER TABLE Appointments DROP COLUMN created_at;
  END IF;
  IF EXISTS(SELECT * FROM information_schema.columns WHERE table_name='appointments' and column_name='for_date') THEN
      ALTER TABLE Appointments RENAME COLUMN for_date TO appointment_date;
  END IF;
END $$;

-- Update DepartmentWaitTimes (for already existing databases)
ALTER TABLE DepartmentWaitTimes ADD COLUMN IF NOT EXISTS current_consultation_start TIMESTAMPTZ;
ALTER TABLE DepartmentWaitTimes ALTER COLUMN current_consultation_start TYPE TIMESTAMPTZ;
ALTER TABLE DepartmentWaitTimes ADD COLUMN IF NOT EXISTS hospital_name VARCHAR(255);

-- Create Admins Table
CREATE TABLE IF NOT EXISTS Admins (
    admin_id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) DEFAULT 'admin',
    hospital_name VARCHAR(255),
    password VARCHAR(255) DEFAULT '000000'
);
