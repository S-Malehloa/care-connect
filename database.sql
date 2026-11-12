CREATE DATABASE IF NOT EXISTS careconnect_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE careconnect_db;

CREATE TABLE IF NOT EXISTS doctors (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  specialty VARCHAR(120) NOT NULL,
  experience VARCHAR(50) NOT NULL,
  description TEXT NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS appointments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  patient_name VARCHAR(150) NOT NULL,
  email VARCHAR(190) NOT NULL,
  phone VARCHAR(40) NOT NULL,
  doctor_id INT NOT NULL,
  date DATE NOT NULL,
  time TIME NOT NULL,
  reason TEXT NOT NULL,
  status ENUM('Pending','Approved','Rejected','Booked','Rescheduled','Confirmed','Completed','Cancelled') NOT NULL DEFAULT 'Pending',
  manager_note TEXT NULL,
  reviewed_by INT NULL,
  reviewed_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_appointments_doctor FOREIGN KEY (doctor_id)
    REFERENCES doctors(id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

ALTER TABLE appointments MODIFY status ENUM('Pending','Approved','Rejected','Booked','Rescheduled','Confirmed','Completed','Cancelled') NOT NULL DEFAULT 'Pending';
ALTER TABLE appointments ADD COLUMN IF NOT EXISTS manager_note TEXT NULL;
ALTER TABLE appointments ADD COLUMN IF NOT EXISTS reviewed_by INT NULL;
ALTER TABLE appointments ADD COLUMN IF NOT EXISTS reviewed_at DATETIME NULL;

INSERT INTO doctors (name,specialty,experience,description)
SELECT * FROM (
  SELECT 'Dr. Thabo Mokoena','General Practitioner','8 years','Provides general health consultations and preventive care.'
  UNION ALL SELECT 'Dr. Lerato Khumalo','Paediatrician','7 years','Specialises in children''s health and development.'
  UNION ALL SELECT 'Dr. Palesa Ndlovu','Cardiologist','10 years','Focuses on heart health and cardiovascular care.'
  UNION ALL SELECT 'Dr. Kabelo Rantšo','Dentist','6 years','Provides dental check-ups and oral health services.'
) AS seed
WHERE NOT EXISTS (SELECT 1 FROM doctors LIMIT 1);


CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(128) NOT NULL,
  password_salt VARCHAR(64) NOT NULL,
  role ENUM('admin','manager','doctor') NOT NULL,
  doctor_id INT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_users_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS patient_notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  appointment_id INT NOT NULL,
  patient_email VARCHAR(190) NOT NULL,
  patient_phone VARCHAR(40) NOT NULL,
  message TEXT NOT NULL,
  channel ENUM('SMS') NOT NULL DEFAULT 'SMS',
  delivery_status VARCHAR(40) NOT NULL DEFAULT 'Saved only',
  provider_sid VARCHAR(100) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notifications_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;
