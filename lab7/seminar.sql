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


--Part 1
CREATE VIEW employee_financial_report AS
    SELECT e.emp_name,
            d.dept_name,
            e.salary
    CASE
    WHEN e.salary > 60000 THEN 'Senior Level'
    WHEN e.salary > 50000 THEN 'MID Level'
    ELSE 'Entry level'
    END AS salary_level

    ROUND ((e.salary*12) + (e.salary * 12 * 0,5))  AS annual_cost, e.salary
        CASE
        WHEN e.salary > 700000 THEN 'High cost'
        WHEN e.salary > 600000 THEN 'Medium cost'
        ELSE 'Standart cost'
    END AS category_cost
FROM employes e TO departments d ON e.dept_id = d.dept ID
ORDER BY annual_cost DESC;

--Part 2
        CREATE VIEW resource_allocation AS
    SELECT
        d.dept_name,
        d.location,
        COUNT (e.emp_id) AS employee_count,
        ROUND(AVG(e.salary),2) AS avg_salary,
        COALESE(SUM(p.budget),0) AS total_p_budget
        ROUND (
        CASE
        WHEN SUM(e.salary) IS NULL OR SUM(e.salary) = 0 THEN 0
        ELSE SUM(p.budget) / SUM (e.salary)
        END , 2
        ) AS res_rat;
        CASE WHEN SUM(p.budget) > 2 THEN 'Over-resourced'
             WHEn SUM(p.budget) = 0 OR SUM(p.budget) is NULL THEN 'No projects'
             WHEn SUM(p.budget) > 0,5 AND SUM(p.budget) < 2.0 THEN 'Well-Balanced'
             ELSE 'Under-resourced'
        END AS all_stata
        FROM d.department
        LEFT JOIN employees e ON d.dept_id = e.dept_id
        LEFT JOIN projects p ON d.dept_id = p.dept_id
            WITH DATA;

    --PArt 3
            CREATE MATERIALIZED VIEW perfomance_dashboard AS
            SELECT
                d.dept_id,
                d.dept_name,
                COALESCE(COUNT(DISTINCT e.emp_id), 0) AS total_employees,
                ROUND (AVG(e.salary),2) AS avg_salary
                COALESCE(COUNT(DISTINCT p.project_id), 0) AS total_projects,
                COALESCE(SUM(p.budget), 0) AS total_project_budget
            CASE (
                WHEN COUNT(e.emp_id) = 0 THEN 0,
                ELSE (COUNT(p.project_id) * 100.0) / COUNT (e.emp_id)
                END, 2
            ) AS effeciency_score
            CASE (
            WHEN (COUNT(p.project_id) * 100.0) / COUNT(e.emp_id) > 50 THEN 'Excellent'
            WHEN WHEN (COUNT(p.project_id) * 100.0) / COUNT(e.emp_id) > 25 THEN 'GOOD if efficency_score'
            ELSE 'Needs improvement'
            ) As perfomance_rating
            FROM d.departments
                LEFT JOIN employees e ON d.dept_id = e.dept_id
                LEFT JOIN projects p ON d.dept_id = p.dept_id
            WITH DATA;

--Part 4
CREATE ROLE  finance_analyst
    GRANT SELECT ON employee_financial_report TO finance_analyst
    GRANT SELECT ON resource_allocation  TO finance_analyst
    GRANT SELECT (e.emp_name,salary ) ON employees TO finance_analyst

CREATE ROLE operations_manager;
GRANT SELECT ON employees, departments, projects TO operations_manager
GRANT SELECT ON MATERIALISED VIEW performance_dashboard To operations_manager
GRANT UPDATE (p.budget) ON projects TO performance_dashboard

--Step 2
CREATE ROLE Team_leader
    GRANT finance_analyst AND operations_manager TO Team_leader
    GRANT Insert On projects to Team_leader,
    GRANT Update(salary) On employess TO Team_leader;

--Step 3
CREATE ROLE sarah_finance LOGIN PASSWORD 'fin2024' TO finance_analyst;
CREATE ROLE  mike_ops LOGIN PASSWORD 'ops2024' TO operations_manager;
CREATE ROLE  jessica_lead LOGIN PASSWORD 'lead2024' TO team_leader;