--Part A
--Task1

CREATE DATABASE IF NOT EXISTS advanced_lab;
CREATE TABLE employees (
    emp_id   SERIAL PRIMARY KEY,
    first_name varchar,
    last_name  varchar,
    department varchar,
    salary     int,
    hire_date  date,
    status varchar DEFAULT 'ACTIVE'
);

CREATE TABLE departments (
    dept_id    SERIAL PRIMARY KEY,
    dept_name  varchar,
    budget     int,
    manager_id int
);

CREATE TABLE projects (
    project_id   SERIAL PRIMARY KEY,
    project_name varchar,
    dept_id      int,
    start_date   date,
    end_date     date,
    budget       int
);

--Part B
--Task B.2 INSERT with column specification
INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (DEFAULT, 'Anatoliy', 'Kim', 'IT');

-- Task B.3 INSERT with Default values 
INSERT INTO employees (salary, statuss)
VALUES (DEFAULT, DEFAULT);

--Task B.4 INSERT multiple rows 
INSERT INTO departments (dept_name, budget, manager_id)
VALUES
  ('Finance',     1, NULL),
  ('Marketing',   12, NULL),
  ('Engineering', 123, NULL);

--Task B.5 INSERT with expressions
INSERT INTO employees (first_name, last_name, department, salary, hire_date)
VALUES ('Anatoliy', 'Kim', 'IT', (50000 * 1.1)::int, CURRENT_DATE);

--Task B.6 INSERT using SELECT
CREATE TABLE IF NOT EXISTS temp_employes
INSERT INTO temp_employes 
    SELECT * FROM employees 
        WHERE department = 'IT';

--Part C 
--Task C.7 UPDATE arithmetic expressions
UPDATE employees SET salary = (salary * 1.10)::int;

--Task C.8 UPDATE with WHERE and multiple condition
    UPDATE employees set statuss = 'Senior' 
        WHERE salary > 60000 and WHERE hire_date <  DATE '2020-01-01' ;

--Task C.9 Update using CASE exp
UPDATE employees SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;

--Task C.10 UPDATE with Default
UPDATE employees set department = DEFAULT where status = 'inactive';

--Tack C.11 Update with Subquery
UPDATE departments SET budget = (s.avg_salary * 1.20)::int
FROM (
    SELECT department AS dept_name, AVG(salary) AS avg_salary
        FROM employees
        GROUP BY department
) WHERE d.dept_name = s.dept_name;

-- Task C.12 UPDATE multiple columns
UPDATE employees SET salary = (salary * 1.15)::int,
    status = 'Promoted'
        WHERE department = 'Sales';

--Part D
--Task D.13 Delete with simple WHERE condition
DELETE * FROM employees WHERE statuss = 'Terminated';
-- Task D.14 DELETE with complex WHERE
DELETE FROM employees
WHERE salary < 40000
  AND hire_date > DATE '2023-01-01'
  AND department IS NULL;

-- Task D.15 DELETE with subquery
DELETE FROM departments d
WHERE NOT EXISTS (
  SELECT 1
  FROM employees e
  WHERE e.department = d.dept_name
);

-- Task D.16 DELETE with RETURNING
DELETE FROM projects
WHERE end_date < DATE '2023-01-01'
RETURNING *;

--Part E. Null operations
--Part E.17
INSERT INTO employees (first_name, last_name, salary , department)
VALUES ('Anatoliy', 'Kim', NULL, NULL);

 
-- Task E.18 UPDATE NULL handling
UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

-- Task.19 DELETE with NULL conditions
DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;

--Part F
-- Task F.20 INSERT with RETURNING
INSERT INTO employees (first_name, last_name, department, salary)
VALUES ('Anatoliy', 'Kim', 'HR', 100000)
RETURNING emp_id, (first_name || ' ' || last_name) AS full_name;

-- Task F.21 UPDATE with RETURNING
UPDATE employees SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

-- Task F.22 DELETE with RETURNING all columns
DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

-- PART G:
-- Task G.23 Conditional INSERT
INSERT INTO employees (first_name, last_name, department)
SELECT 'Timur', 'Kim', 'IT'
WHERE NOT EXISTS (
    SELECT 1 FROM employees
    WHERE first_name = 'Timur' AND last_name = 'Kim'
);

-- Task G.24 UPDATE with JOIN logic using subqueries
UPDATE employees e
SET salary = (
  salary * CASE
    WHEN (SELECT d.budget FROM departments d
          WHERE d.dept_name = e.department) > 100000 THEN 1.10
    ELSE 1.05
  END
)::int;

-- Task G.25 Bulk operations
INSERT INTO employees (first_name, last_name, department, salary)
VALUES 
  ('Emp1','One','IT',45000),
  ('Emp2','Two','IT',46000),
  ('Emp3','Three','IT',47000),
  ('Emp4','Four','IT',48000),
  ('Emp5','Five','IT',49000);

UPDATE employees
SET salary = (salary * 1.10)::int
WHERE (first_name, last_name) IN (
  ('Emp1','One'),('Emp2','Two'),('Emp3','Three'),('Emp4','Four'),('Emp5','Five')
);

-- Task G.26 Data migration simulation
CREATE TABLE employee_archive AS
SELECT * FROM employees WHERE FALSE;

INSERT INTO employee_archive
SELECT * FROM employees
WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';

-- Task G.27 Complex business logic
UPDATE projects p
SET end_date = COALESCE(p.end_date, CURRENT_DATE) + INTERVAL '30 days'
WHERE p.budget > 50000
  AND EXISTS (
      SELECT 1
      FROM departments d
      JOIN employees e ON e.department = d.dept_name
      WHERE d.dept_id = p.dept_id
      GROUP BY d.dept_id
      HAVING COUNT(*) > 3
  );