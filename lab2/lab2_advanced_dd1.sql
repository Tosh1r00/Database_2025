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
                                start_time TIME without time zone,
                                end_time TIME without time zone,
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

-- PART 4:
--Task 4.1:
CREATE TABLE departments (
                             department_id SERIAL PRIMARY KEY,
                             department_name varchar(100),
                             department_code char(5),
                             building varchar(50),
                             phone varchar(15),
                             budget decimal(15, 2),
                             established_year int
);

CREATE TABLE library_books (
                               book_id SERIAL PRIMARY KEY,
                               isbn char(13),
                               title varchar(200),
                               author varchar(100),
                               publisher varchar(100),
                               publication_date date,
                               price decimal(10, 2),
                               is_available boolean,
                               acquisition_timestamp timestamp
);

CREATE TABLE student_book_loans (
                                    loan_id SERIAL PRIMARY KEY,
                                    student_id int,
                                    book_id int,
                                    loan_date date,
                                    due_date date,
                                    return_date date,
                                    fine_amount decimal(6, 2),
                                    loan_status varchar(20)
);
--Task 4.2:
ALTER TABLE professors
    ADD COLUMN department_id int;

ALTER TABLE students
    ADD COLUMN advisor_id int;

ALTER TABLE courses
    ADD COLUMN department_id int;

CREATE TABLE grade_scale (
                             grade_id SERIAL PRIMARY KEY,
                             letter_grade char(2),
                             min_percentage decimal(4, 1),
                             max_percentage decimal(4, 1),
                             gpa_points decimal(3, 2)
);

CREATE TABLE semester_calendar (
                                   semester_id SERIAL PRIMARY KEY,
                                   semester_name varchar(20),
                                   academic_year int,
                                   start_date date,
                                   end_date date,
                                   registration_deadline timestamptz,
                                   is_current boolean
);
-- PART 5: Cleanup Operations
DROP TABLE IF EXISTS student_book_loans;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS grade_scale;

CREATE TABLE grade_scale (
                             grade_id SERIAL PRIMARY KEY,
                             letter_grade char(2),
                             min_percentage decimal(4, 1),
                             max_percentage decimal(4, 1),
                             gpa_points decimal(3, 2),
                             description text
);

DROP TABLE IF EXISTS semester_calendar CASCADE;

CREATE TABLE semester_calendar (
                                   semester_id SERIAL PRIMARY KEY,
                                   semester_name varchar(20),
                                   academic_year int,
                                   start_date date,
                                   end_date date,
                                   registration_deadline timestamptz,
                                   is_current boolean
);

--Task 5.2:
DROP DATABASE IF EXISTS university_test;
DROP DATABASE IF EXISTS university_distributed;

CREATE DATABASE university_backup
    TEMPLATE university_main;



--Part A
CREATE DATABASE library_system
    CONNECTION LIMIT = 75;
CREATE TABLESPACE digital_content LOCATION "/storage/ebooks"

--Part B
CREATE TABLE book_catalog(
    catalog_id SERIAL PRIMARY KEY,
    isbn CHAR(13),
    book_title VARCHAR (150),
    author_name VARCHAR (100),
    publisher VARCHAR (80),
    publication_year SMALLINT,
    total_pages INT,
    book_format CHAR(10),
    purchase_prise DECIMAL(3,2),
    is_available BOOLEAN;
)
CREATE TABLE digital_downloads(
    download_id SERIAL PRIMARY KEY,
    user_id INT,
    catalog_id INT,
    download_stamp TIMESTAMP WITHOUT TIME ZONE,
    file_format VARCHAR(10),
    file_size_mb real INT,
    download_completed BOOLEAN,
    expiry_date DATE,
    access_count SMALLINT; 
)

--PART C
ALTER TABLE book_catalog
    ADD COLUMN genre VARCHAR(50),
    ADD COLUMN library_section CHAR(3),
    ALTER COLUMN genre SET DEFAULT 'UNKNOWN';
ALTER TABLE digital_downloads
    ADD COLUMN device_type VARCHAR(30),
    ALTER COLUMN file_size_mb TYPE INT,
    ADD COLUMN last_accessed TIMESTAMP with TIME ZONE;

--PART D
CREATE TABLE reading_sessions(
    session_id SERIAL PRIMARY KEY,
    user_reference INT,
    book_reference INT,
    session_start TIMESTAMP with Time Zone,
    reading_duration INTERVAL(9),
    pages_read SMALLINT,
    session_active BOOLEAN;
)