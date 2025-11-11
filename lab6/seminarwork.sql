--Part 1
CREATE TABLE employees (
 emp_id INT PRIMARY KEY,
 emp_name VARCHAR(50),
 dept_id INT,
 salary DECIMAL(10, 2)
);

CREATE TABLE departments (
 dept_id INT PRIMARY KEY,
 dept_name VARCHAR(50),
 location VARCHAR(50)
);

CREATE TABLE projects (
 project_id INT PRIMARY KEY,
 project_name VARCHAR(50),
 dept_id INT,
 budget DECIMAL(10, 2)
);

--Task 1
SELECT e.emp_name, d.dept_name,d.location ,e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept.id
ORDER by e.emp_name

--Task2
SELECT  d.dept_name, e.employee_count ,e.salary
     COUNT (e.emp_id) AS employee_count,
     AVG(e.salary) AS avg_sal
     FROM department d
      LEFT Join employees e ON d.dept_id = e.dept_id
      ORDER BY d.dept_id, d.dept_name
      ORDER BY emplyee_count DESC;

--task 3
SELECT  e.resource_type, e.resource_name ,e.value
    FROM employees e
    LEFT JOIN departments d ON e.dept_id = d.dept_id
    where d.dept_id is null
UNION
SELECT p.project_name, p.budget
    FROM projects p
    LEFT JOIN p.departments d on p.dept_id = d.dept_id
    where d.dept_id is  null;



--Task 4
SELECT d.dept_name, d.location
  COUNT (p.projects_id) AS project_count
  COUNT (p.projects_id) AS projetc_budget
FROM projects p ON d.dept_id = p.dept_id
WHERE p.dept_id is not null
ORDER BY projects_budget DESC;

