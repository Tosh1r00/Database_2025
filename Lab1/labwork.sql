--Lab 8

-- Create tables
CREATE TABLE departments (
 dept_id INT PRIMARY KEY,
 dept_name VARCHAR(50),
 location VARCHAR(50)
);
CREATE TABLE employees (
 emp_id INT PRIMARY KEY,
 emp_name VARCHAR(100),
 dept_id INT,
 salary DECIMAL(10,2),
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
CREATE TABLE projects (
 proj_id INT PRIMARY KEY,
 proj_name VARCHAR(100),
 budget DECIMAL(12,2),
 dept_id INT,
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
-- Insert sample data
INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Operations', 'Building C');
INSERT INTO employees VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 101, 55000),
(3, 'Mike Johnson', 102, 48000),
(4, 'Sarah Williams', 102, 52000),
(5, 'Tom Brown', 103, 60000);
INSERT INTO projects VALUES
(201, 'Website Redesign', 75000, 101),
(202, 'Database Migration', 120000, 101),
(203, 'HR System Upgrade', 50000, 102);

-- Part 2.1: Creating Basic Indexes
CREATE INDEX emp_salary_idx ON employees(salary); --Create an index on the salary column of the employees table
/*
На таблице employees теперь 2 индекса:
Автоматический индекс по PRIMARY KEY (emp_id).
Мы создали emp_salary_idx.*/

-- Part 2.2: Create an Index on a Foreign Key
CREATE INDEX emp_dept_idx ON employees(dept_id);
SELECT * FROM employees WHERE dept_id = 101;
/*
Индекс на dept_id полезен, потому что foreign key часто используется:
в JOIN-ах, в фильтрах WHERE, при проверке ссылочной целостности.
Он ускоряет выборки по dept_id.
*/

--Part 2.3
-- View all indexes in your database
SELECT
 tablename,
 indexname,
 indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Part3

--Task 3.1
CREATE INDEX emp_dept_salary_idx ON employess(dept_id, salary);
--TEST
SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;
--if the query filters only by salary, the index will NOT be used, because multicolumn indexes work left-to-right.


--Task 3.2
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);
--TEST
SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;
SELECT * FROM emplyees WHERE salary > 50000 AND dept_id = 102;

/*
Index (salary, dept_id):
works well when filtering starts with salary
is not helpful for queries filtering only by dept_id

Index (dept_id, salary):
works well when filtering starts with dept_id
won’t be used if dept_id is not included in the filter

Conclusion:
PostgreSQL uses multicolumn indexes left-to-right only.
*/

--Part 4: Unique Indexes
ALTER TABLE employees ADD COLUMN email VARCHAR(100);
UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

--TEST
INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');

/*
ERROR:  duplicate key value violates unique constraint "emp_email_unique_idx"
DETAIL:  Key (email)=(john.smith@company.com) already exists.
*/

--Task 4.2
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;

--TEST
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';
/*
Тип индекса: B-tree, потому что UNIQUE всегда создаёт B-tree индекс.
То есть UNIQUE constraint = автоматическое создание уникального индекса.*/

--Part 5
--Task 5.1
CREATE INDEX emp_salary_desc_idx ON employees (salary DESC);

--TEST
SELECT emp_name,salary
FROM employees
ORDER BY salary DESC

/*Этот индекс хранит значения salary в уже отсортированном виде по убыванию.
Поэтому PostgreSQL может:
сделать Index Scan вместо сортировки,
пропустить стадию Sort,
вернуть строки уже в нужном порядке.

Это ускоряет ORDER BY salary DESC особенно для больших таблиц.*/

--Task 5.2
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);
--TEST
SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;

/* Индекс учитывает правило сортировки: сначала идут NULL-значения.
PostgreSQL может использовать этот индекс, чтобы сразу вернуть строки в порядке, где NULL стоят первыми, без лишней сортировки*/

--Part 6
--Task 6.1
CREATE INDEX proj_budget_lower_idx ON employees (LOWER(emp_name));
--TEST
SELECT * FROM employees WHERE LOWER(emp_name) = 'john_smith';

/*С expression-index PostgreSQL хранит заранее вычисленное LOWER(emp_name) внутри индекса,
поэтому поиск сразу идёт по индексу — быстрее в разы.*/

--Task 6.2
ALTER TABLE employees ADD COLUMN hire_date DATE;
UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

--TEST
CREATE INDEX emp_hire_date_idx ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;

/*С EXTRACT(YEAR FROM hire_date) год хранится заранее → фильтрация по году выполняется по индексу → быстро. */

--Part 7: Managing Indexes
--Task 7.1

ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;
--TEST
SELECT indexname FROM pg_indexes WHERE tablename = 'employees';

--Task 7.2
DROP INDEX emp_salary_dept_idx;

--Task 7.3
REINDEX INDEX employees_salary_index;
/*Это полезно:
после массовых INSERT,
когда индекс стал bloated (раздут),
после больших UPDATE/DELETE,

при повреждении индекса.*/

--Part 8
--Task 8.1

SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

--TEST
CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;

--Task 8.2
CREATE INDEX proj_high_budget_idx ON projects(budget) WHERE budget > 80000;
--Test 
SELECT proj_name, budget
FROM projects
WHERE budget > 80000;

/*Преимущество частичного индекса:
индекс меньше по размеру,
покрывает только нужную часть таблицы,
быстрее создаётся,
быстрее используется,
уменьшает нагрузку на INSERT/UPDATE/DELETE.

Он идеально подходит, когда ты часто фильтруешь subset данных.
*/

--Task 8.3
EXPLAIN SELECT * FROM employees WHERE salary > 52000;

--Part 9 Hash Indexes:
--Task 9.1
CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);
--TEST
SELECT * FROM departments WHERE dept_name ='IT';
/*HASH-индекс полезен только для операций равенства:
=,
IN ( ... ) в некоторых случаях;

Он не поддерживает:
диапазоны (>, <, BETWEEN),
сортировку,
упорядоченность данных;

Использовать HASH индекс стоит, когда:
только equality-поиски, и много повторяющихся значений.
Чаще всего B-tree лучше, но hash подходит для узких кейсов.*/

--Task 9.2
CREATE INDEX proj_name_btree_idx ON projects(proj_name); --B-tree index
CREATE INDEX proj_name_hash_idx ON projects USING HASH (proj_name); -- hash index

-- difference is in range when usign WHERE clauses


--Part 10
--Task 10.1

SELECT 
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
/*Самый большой индекс обычно:
PRIMARY KEY индексы (например employees_pkey),
multicolumn индекс,
индекс на колонке с большим количеством уникальных значений.*/
--Task 10.2
DROP INDEX IF EXISTS proj_name_hash_idx;


--Task 10.3
CREATE VIEW index_documentation AS
SELECT
 tablename,
 indexname,
 indexdef,
 'Improves salary-based queries' as purpose
FROM pg_indexes
WHERE schemaname = 'public'
AND indexname LIKE '%salary%'

SELECT * FROM index_documentation;

/*Создано представление, которое документирует все индексы, связанные с salary,
и хранит цель каждого индекса.
Это помогает:
понимать зачем каждый индекс нужен,
поддерживать документацию,
анализировать влияние на запросы.*/

--Summary Questions
/*

2)Name three scenarios where you should create an index:
частые фильтры в WHERE
JOIN по колонке
ORDER BY по колонке

3)Name two scenarios where you should NOT create an index:
small-size table
frequent operations INSERT/UPDATE/DELETE

4)What happens to indexes when you INSERT, UPDATE, or DELETE data?
Вставка/обновление/удаление → требует обновлять каждый индекс → замедляет write.

5)How can you check if a query is using an index?
use EXPLAIN
*/