--PArt1

CREATE TABLE membership_plans(
    plan_id SERIAL PRIMARY KEY,
    plan_name TEXT NOT NULL UNIQUE,
    monthly_fee NUMERIC NOT NULL check ( monthly_free BETWEEN 10 AND 50),
    max_classes_per_month INT check ( max_classes_per_month BETWEEN 0 AND 100),
    includes_personal_trainer BOOLEAN NOT NULL DEFAULT false,
);

INSERT INTO membership_plans (plan_id,plan_name,monthly_fee)
VALUES ('1', 'Basic', 30),
       ('2', 'Premium', 60),
       ('3','VIP',100);

INSERT INTO membership_plans (plan_id,plan_name,monthly_fee)
VALUES ('1', 'Basic', 5),

INSERT INTO membership_plans (plan_id,plan_name,monthly_fee)
VALUES ('1', 'Basic', 30),

--Task 2
CREATE TABLE gym_members(
    member_id  INT, PRIMARY KEY
    full_name text, NOT NULL
    email text, NOT NULL, UNIQUE
    phone text, NOT NULL
    date_of_birth date, NOT NULL
    plan_id integer, NOT NULL, REFERENCES membership_plans
    join_date date, NOT NULL, DEFAULT CURRENT_DATE
    emergency_contact text

    CONSTRAINT date_of_birth CHECK (
          date_of_birth > 16;
        ) 
    CONSTRAINT join_date CHECK (
          join_date < CURRENT_DATE;
        )     
);

INSERT INTO gym_members (member_id,full_name,date_of_birth,join_date)
VALUES (1,'Anatoiy',17,14.10.2025), (2,'Tim',17,14.10.2025), (3,'Vlad',17,14.10.2025);


INSERT INTO gym_members (member_id,full_name,date_of_birth,join_date)
VALUES (4,'Den',10,14.10.2025);

INSERT INTO gym_members (member_id,full_name,date_of_birth,join_date)
VALUES (5,'Denis',18,01.01.2026);

INSERT INTO gym_members (member_id,full_name,date_of_birth,join_date)
VALUES (999,'Deniska',18,14.10.2025);

-- Task 3: 
CREATE TABLE trainers (
    trainer_id INT, PRIMARY KEY,
    first_name TEXT, NOT NULL,
    last_name TEXT, NOT NULL,
    email TEXT, NOT NULL, UNIQUE,
    specialization TEXT , NOT NULL , CHECK (specialization IN ('Yoga', 'Cardio', 'stratching')),
    hourly_rate NUMERIC , NOT NULL , CHECK (hourly_rate BETWEEN 20 AND 200),
    certification_number TEXT , NOT NULL , UNIQUE,
    years_experience INT,  CHECK (years_experience BETWEEN 0 AND 50)
);


INSERT INTO trainers (trainer_id,first_name,last_name,email,specialization,certification_number)
VALUES (1, 'Tol', 'Kim', 'tool.kim@gmail.com', 'Yoga', 001),
       (2, 'Tim', 'Kim', 'tim.kim@gmail.com', 'Stretching', 002),
       (3, 'Vlad', 'Lox', 'Vlad.loz@gmail.com', 'Cardio', 003);

INSERT INTO trainers VALUES (4, 'Anna', 'D', 'anns.d@gmail.com', 'Dance', 004);
INSERT INTO trainers VALUES (5, 'Tom', 'Dim', 'tom.dim@gmail.com', 'Cardio', 003);

