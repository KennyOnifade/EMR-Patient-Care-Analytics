-- EMR Patient Care Analytics Database
-- Author: Kehinde Onifade
-- Description: SQL script to create and analyze a healthcare EMR system
-- Database + Tables + Data
-- Create database
IF DB_ID('EMR_System') IS NULL
CREATE DATABASE EMR_System;
GO

USE EMR_System;
GO

-- Drop old tables first
DROP TABLE IF EXISTS Appointments;
DROP TABLE IF EXISTS PatientConditions;
DROP TABLE IF EXISTS Conditions;
DROP TABLE IF EXISTS Doctors;
DROP TABLE IF EXISTS Patients;
GO

-- Patients table
CREATE TABLE Patients (
    patient_id INT IDENTITY(1,1) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    gender VARCHAR(10),
    email VARCHAR(100),
    created_at DATE DEFAULT GETDATE()
);

-- Doctors table
CREATE TABLE Doctors (
    doctor_id INT IDENTITY(1,1) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100) NOT NULL,
    department VARCHAR(100)
);

-- Conditions table
CREATE TABLE Conditions (
    condition_id INT IDENTITY(1,1) PRIMARY KEY,
    condition_name VARCHAR(100) NOT NULL UNIQUE
);

-- PatientConditions table
CREATE TABLE PatientConditions (
    patient_id INT NOT NULL,
    condition_id INT NOT NULL,

    PRIMARY KEY (patient_id, condition_id),

    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (condition_id) REFERENCES Conditions(condition_id)
);

-- Appointments table
CREATE TABLE Appointments (
    appointment_id INT IDENTITY(1,1) PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_status VARCHAR(30) NOT NULL,
    visit_reason VARCHAR(200),

    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);
GO

-- Insert Patients
INSERT INTO Patients (full_name, age, gender, email)
VALUES
('John Doe', 45, 'Male', 'john.doe@email.com'),
('Jane Smith', 30, 'Female', 'jane.smith@email.com'),
('Alice Brown', 25, 'Female', 'alice.brown@email.com'),
('Bob Wilson', 50, 'Male', 'bob.wilson@email.com'),
('Eve Davis', 40, 'Female', 'eve.davis@email.com'),
('Michael Johnson', 62, 'Male', 'michael.johnson@email.com'),
('Sarah Adams', 35, 'Female', 'sarah.adams@email.com'),
('David Clark', 28, 'Male', 'david.clark@email.com'),
('Grace Miller', 55, 'Female', 'grace.miller@email.com'),
('Peter Thomas', 48, 'Male', 'peter.thomas@email.com');

-- Insert Doctors
INSERT INTO Doctors (full_name, specialty, department)
VALUES
('Dr. Emily Carter', 'Cardiology', 'Heart Care'),
('Dr. James White', 'Endocrinology', 'Diabetes Care'),
('Dr. Linda Green', 'Pulmonology', 'Respiratory Care'),
('Dr. Mark Taylor', 'General Medicine', 'Primary Care');

-- Insert Conditions
INSERT INTO Conditions (condition_name)
VALUES
('flu'),
('hypertension'),
('diabetes'),
('asthma'),
('chest pain'),
('malaria');

-- Insert Patient Conditions
INSERT INTO PatientConditions (patient_id, condition_id)
VALUES
(1,1),(1,2),
(2,2),(2,3),
(3,4),(3,1),
(4,2),(4,3),(4,4),
(5,1),
(6,2),(6,5),
(7,3),
(8,6),
(9,2),(9,3),
(10,5);

-- Insert Appointments
INSERT INTO Appointments 
(patient_id, doctor_id, appointment_date, appointment_status, visit_reason)
VALUES
(1,4,'2026-04-01','Completed','Flu symptoms'),
(1,1,'2026-04-10','Completed','Blood pressure check'),
(2,2,'2026-04-05','Completed','Diabetes follow-up'),
(3,3,'2026-04-08','Cancelled','Asthma review'),
(4,2,'2026-04-12','Completed','Diabetes and hypertension check'),
(5,4,'2026-04-15','No Show','Flu symptoms'),
(6,1,'2026-04-16','Completed','Chest pain'),
(7,2,'2026-04-18','Scheduled','Diabetes consultation'),
(8,4,'2026-04-19','Completed','Malaria treatment'),
(9,2,'2026-04-20','Completed','Diabetes review'),
(10,1,'2026-04-21','Scheduled','Chest pain evaluation');
GO


-- Real-World Analytics SQL Queries
-- Query 1:Patient appointment history

SELECT
    p.full_name AS patient_name,
    p.age,
    d.full_name AS doctor_name,
    d.specialty,
    a.appointment_date,
    a.appointment_status,
    a.visit_reason
FROM Appointments a
JOIN Patients p
    ON a.patient_id = p.patient_id
JOIN Doctors d
    ON a.doctor_id = d.doctor_id
ORDER BY a.appointment_date;



-- Query 2: Count patients per medical condition
SELECT
    c.condition_name,
    COUNT(pc.patient_id) AS number_of_patients
FROM Conditions c
JOIN PatientConditions pc
    ON c.condition_id = pc.condition_id
GROUP BY c.condition_name
ORDER BY number_of_patients DESC;



-- Query 3: Appointment status summary
SELECT
    appointment_status,
    COUNT(*) AS total_appointments
FROM Appointments
GROUP BY appointment_status
ORDER BY total_appointments DESC;



-- Query 4: Doctors with the highest number of appointments
SELECT
    d.full_name AS doctor_name,
    d.specialty,
    COUNT(a.appointment_id) AS total_appointments
FROM Doctors d
JOIN Appointments a
    ON d.doctor_id = a.doctor_id
GROUP BY d.full_name, d.specialty
ORDER BY total_appointments DESC;




-- Query 5: Patients with more than one condition
SELECT
    p.full_name,
    COUNT(pc.condition_id) AS number_of_conditions
FROM Patients p
JOIN PatientConditions pc
    ON p.patient_id = pc.patient_id
GROUP BY p.full_name
HAVING COUNT(pc.condition_id) > 1
ORDER BY number_of_conditions DESC;



-- Query 6:Patients who missed or cancelled appointments
SELECT
    p.full_name AS patient_name,
    a.appointment_date,
    a.appointment_status,
    a.visit_reason
FROM Appointments a
JOIN Patients p
    ON a.patient_id = p.patient_id
WHERE a.appointment_status IN ('Cancelled', 'No Show')
ORDER BY a.appointment_date;




--Query 7:Department appointment workload
SELECT
    d.department,
    COUNT(a.appointment_id) AS total_appointments
FROM Doctors d
JOIN Appointments a
    ON d.doctor_id = a.doctor_id
GROUP BY d.department
ORDER BY total_appointments DESC;