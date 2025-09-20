--Part 1
-- T 1.1

--DB main
DROP DATABASE IF EXISTS university_main;
CREATE DATABASE university_main
    TEMPLATE = template0
    ENCODING = 'UTF8';
ALTER DATABASE university_main OWNER TO CURRENT_USER;

--DB archive
DROP DATABASE IF EXISTS university_archive;
CREATE DATABASE university_archive
    CONNECTION LIMIT = 50
    TEMPLATE = template0;

--DB test
CREATE DATABASE university_test
    CONNECTION LIMIT = 10
    IS_TEMPLATE = TRUE;

-- T1.2
DROP DATABASE IF EXISTS university_distributed;
DROP TABLESPACE IF EXISTS student_data;
DROP TABLESPACE IF EXISTS course_data;

CREATE TABLESPACE student_data LOCATION '/tmp/students';
CREATE TABLESPACE course_data  OWNER CURRENT_USER LOCATION '/tmp/courses';

CREATE DATABASE university_distributed
    TABLESPACE student_data
    ENCODING 'LATIN9'
    TEMPLATE template0;

-- Part 2 — Table Creation
DROP TABLE IF EXISTS enrollments CASCADE;
DROP TABLE IF EXISTS teach CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS professors CASCADE;
DROP TABLE IF EXISTS students CASCADE;

CREATE TABLE students (
                          student_id     SERIAL PRIMARY KEY,
                          first_name     VARCHAR(50)  NOT NULL,
                          last_name      VARCHAR(50)  NOT NULL,
                          email          VARCHAR(100),
                          gpa            NUMERIC(3,2) CHECK (gpa BETWEEN 0 AND 4.00),
                          enrollment_date DATE DEFAULT CURRENT_DATE,
                          preferred_time TIME WITHOUT TIME ZONE,
                          last_login_at  TIMESTAMPTZ,
                          study_quota    INTERVAL,
                          is_full_time   BOOLEAN DEFAULT TRUE,
                          bio            TEXT
);

CREATE TABLE professors (
                            professor_id BIGSERIAL PRIMARY KEY,
                            first_name   VARCHAR(50) NOT NULL,
                            last_name    VARCHAR(50) NOT NULL,
                            hire_date    DATE NOT NULL,
                            rating       REAL,
                            h_index      DOUBLE PRECISION,
                            is_tenured   BOOLEAN DEFAULT FALSE
);

CREATE TABLE courses (
                         course_id   SMALLSERIAL PRIMARY KEY,
                         code        CHAR(6) UNIQUE NOT NULL,
                         title       VARCHAR(100) NOT NULL,
                         credits     SMALLINT NOT NULL CHECK (credits BETWEEN 1 AND 10),
                         tuition_fee DECIMAL(8,2) DEFAULT 0.00
);

CREATE TABLE enrollments (
                             enrollment_id SERIAL PRIMARY KEY,
                             student_id    INTEGER NOT NULL,
                             course_id     INTEGER NOT NULL,
                             enrolled_at   TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
                             grade_raw     REAL,
                             final_score   DOUBLE PRECISION
);

CREATE TABLE teach (
                       professor_id BIGINT  NOT NULL,
                       course_id    INTEGER NOT NULL,
                       PRIMARY KEY (professor_id, course_id)
);

-- Part 3 — ALTER Operations
ALTER TABLE students ADD COLUMN phone CHAR(12);
ALTER TABLE students ALTER COLUMN gpa TYPE NUMERIC(4,2) USING gpa::NUMERIC(4,2);
ALTER TABLE courses ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE courses RENAME COLUMN title TO name;
ALTER TABLE courses RENAME COLUMN name TO title;
ALTER TABLE professors RENAME TO faculty;
ALTER TABLE faculty RENAME TO professors;

-- Part 4 — Table Management (constraints, FKs, indexes)
ALTER TABLE enrollments
    ADD CONSTRAINT fk_enr_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_enr_course  FOREIGN KEY (course_id)  REFERENCES courses(course_id)  ON DELETE CASCADE;

ALTER TABLE teach
    ADD CONSTRAINT fk_teach_prof   FOREIGN KEY (professor_id) REFERENCES professors(professor_id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_teach_course FOREIGN KEY (course_id)    REFERENCES courses(course_id)    ON DELETE CASCADE;

ALTER TABLE professors
    ADD CONSTRAINT chk_hindex_nonneg CHECK (h_index IS NULL OR h_index >= 0);

ALTER TABLE students
    ADD CONSTRAINT uq_students_email UNIQUE (email);

CREATE INDEX IF NOT EXISTS idx_students_last_first ON students(last_name, first_name);
CREATE INDEX IF NOT EXISTS idx_courses_active       ON courses(is_active);
CREATE INDEX IF NOT EXISTS idx_enr_student_course   ON enrollments(student_id, course_id);

-- Part 5 — Cleanup Operations
 DROP TABLE IF EXISTS enrollments CASCADE;
 DROP TABLE IF EXISTS teach CASCADE;
 DROP TABLE IF EXISTS courses CASCADE;
 DROP TABLE IF EXISTS professors CASCADE;
 DROP TABLE IF EXISTS students CASCADE;

