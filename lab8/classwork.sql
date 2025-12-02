--Part
CREATE TABLE patients (
                          patient_id INT PRIMARY KEY,
                          first_name VARCHAR(50),
                          last_name VARCHAR(50),
                          date_of_birth DATE,
                          phone VARCHAR(20),
                          insurance_id VARCHAR(50)
);
CREATE TABLE appointments (
                              appointment_id INT PRIMARY KEY,
                              patient_id INT,
                              doctor_name VARCHAR(100),
                              appointment_date DATE,
                              appointment_time TIME,
                              status VARCHAR(20),
                              department VARCHAR(50),
                              FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

--Task 1
CREATE INDEX patient_last_name ON patients USING HASH (last_name) ;
/*
HASH-index nотому что когда мы ищем конкретную фамилию мы используем точное сравнение '='
*/

--Task 2
CREATE INDEX date_idx ON appointments(appointments_date);
/*
 B-tree лучше потому HASH не работает с датой. То же самое и для условия WHERE, где мы можем искать DATE через сравнения (>= or <=)
 */

 --Task 3
CREATE INDEX idx_schedule ON appointments(appointment_date, status)
SELECT appointments.appointment_date WHERE status = 'Scheduled';
-- I guess less because we search not for every status but only for 10% of it, so the required space must be less

--Task 4
    SELECT * FROM appointments
    WHERE department = 'Cardiology'
         AND appointment_date = '2025-11-20'
         AND status = 'Scheduled';
CREATE INDEX appoint_idx ON appointments(department, appointment_date, status);

-- I guess Yes, because the  indexes left-to-right используется при создании Индекса и поэтому если порядок будет неправильный то и аутпут