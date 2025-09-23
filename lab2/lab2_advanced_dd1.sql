-- PART 1:
-- Task 1.1:

-- DB main
DROP DATABASE IF EXISTS university_main;
CREATE DATABASE university_main
    TEMPLATE template0
    ENCODING 'UTF8';
ALTER DATABASE university_main OWNER TO CURRENT_USER;

-- DB archive
DROP DATABASE IF EXISTS university_archive;
CREATE DATABASE university_archive
    CONNECTION LIMIT = 50
    TEMPLATE template0;

-- DB test
CREATE DATABASE university_test
    CONNECTION LIMIT = 10
    IS_TEMPLATE TRUE;

-- Task 1.2:
DROP DATABASE IF EXISTS university_distributed;
DROP TABLESPACE IF EXISTS student_data;
DROP TABLESPACE IF EXISTS course_data;

CREATE TABLESPACE student_data LOCATION '/data/students';
CREATE TABLESPACE course_data OWNER CURRENT_USER LOCATION '/data/courses';

CREATE DATABASE university_distributed
    TABLESPACE student_data
    ENCODING 'LATIN9'
    TEMPLATE template0;

-- PART 2: Table Creation
DROP TABLE IF EXISTS enrollments CASCADE;
DROP TABLE IF EXISTS teach CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS professors CASCADE;
DROP TABLE IF EXISTS students CASCADE;

CREATE TABLE students (
                          student_id SERIAL PRIMARY KEY,
                          first_name VARCHAR(50),
                          last_name VARCHAR(50),
                          email VARCHAR(100),
                          phone CHAR(15),
                          date_of_birth DATE,
                          enrollment_date DATE,
                          gpa DECIMAL(3, 2),
                          is_active BOOLEAN,
                          graduation_year SMALLINT
);

CREATE TABLE professors (
                            professor_id SERIAL PRIMARY KEY,
                            first_name VARCHAR(50),
                            last_name VARCHAR(50),
                            email VARCHAR(100),
                            office_number VARCHAR(20),
                            hire_date DATE,
                            salary DECIMAL(12, 2),
                            is_tenured BOOLEAN,
                            years_experience INT
);

CREATE TABLE courses (
                         course_id SERIAL PRIMARY KEY,
                         course_code CHAR(8),
                         course_title VARCHAR(100),
                         description TEXT,
                         credits SMALLINT,
                         max_enrollment INT,
                         course_fee DECIMAL(10, 2),
                         is_online BOOLEAN,
                         created_at TIMESTAMP
);

-- Task 2.2:
CREATE TABLE class_schedule (
                                schedule_id SERIAL PRIMARY KEY,
                                course_id INT,
                                professor_id INT,
                                classroom VARCHAR(20),
                                class_date DATE,
                                start_time TIME,
                                end_time TIME,
                                duration INTERVAL
);

CREATE TABLE student_records (
                                 record_id SERIAL PRIMARY KEY,
                                 student_id INT,
                                 course_id INT,
                                 semester VARCHAR(20),
                                 year INT,
                                 grade CHAR(2),
                                 attendance_percentage DECIMAL(5, 1),
                                 submission_timestamp TIMESTAMPTZ,
                                 last_updated TIMESTAMPTZ
);

-- PART 3: ALTER Operations
ALTER TABLE students
    ADD COLUMN middle_name VARCHAR(30),
    ADD COLUMN student_status VARCHAR(20),
    ALTER COLUMN phone TYPE VARCHAR(20),
    ALTER COLUMN student_status SET DEFAULT 'ACTIVE',
    ALTER COLUMN gpa SET DEFAULT 0.00;

ALTER TABLE professors
    ADD COLUMN department_code CHAR(5),
    ADD COLUMN research_area TEXT,
    ALTER COLUMN years_experience TYPE SMALLINT,
    ALTER COLUMN is_tenured SET DEFAULT FALSE,
    ADD COLUMN last_promotion_date DATE;

ALTER TABLE courses
    ADD COLUMN prerequisite_course_id INT,
    ADD COLUMN difficulty_level SMALLINT,
    ALTER COLUMN course_code TYPE VARCHAR(10),
    ALTER COLUMN credits SET DEFAULT 3,
    ADD COLUMN lab_required BOOLEAN DEFAULT FALSE;

-- Task 3.2:
ALTER TABLE class_schedule
    ADD COLUMN room_capacity INT,
    DROP COLUMN duration,
    ADD COLUMN session_type VARCHAR(15),
    ALTER COLUMN classroom TYPE VARCHAR(30),
    ADD COLUMN equipment_needed TEXT;

ALTER TABLE student_records
    ADD COLUMN extra_credit_points DECIMAL(3, 1),
    ALTER COLUMN grade TYPE VARCHAR(5),
    ALTER COLUMN extra_credit_points SET DEFAULT 0.0,
    ADD COLUMN final_exam_date DATE,
    DROP COLUMN last_updated;

-- PART 4: Table Management (constraints, FKs, indexes)
ALTER TABLE enrollments
    ADD CONSTRAINT fk_enr_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_enr_course FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE;

ALTER TABLE teach
    ADD CONSTRAINT fk_teach_prof FOREIGN KEY (professor_id) REFERENCES professors(professor_id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_teach_course FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE;

ALTER TABLE professors
    ADD CONSTRAINT chk_hindex_nonneg CHECK (h_index IS NULL OR h_index >= 0);

ALTER TABLE students
    ADD CONSTRAINT uq_students_email UNIQUE (email);

CREATE INDEX IF NOT EXISTS idx_students_last_first ON students(last_name, first_name);
CREATE INDEX IF NOT EXISTS idx_courses_active ON courses(is_active);
CREATE INDEX IF NOT EXISTS idx_enr_student_course ON enrollments(student_id, course_id);

-- PART 5: Cleanup Operations
DROP TABLE IF EXISTS enrollments CASCADE;
DROP TABLE IF EXISTS teach CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS professors CASCADE;
DROP TABLE IF EXISTS students CASCADE;

