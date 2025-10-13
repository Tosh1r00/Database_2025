--Kim Anatoliy 24B031848
--Part1
--T.1.1

CREATE TABLE employyes(
    employee_id INT,
    first_name text,
    age INT CHECK (age BETWEEN 18 and 65),
    salary numeric CHECK (salary > 0);
)

--Task 1.2
CREATE TABLE products_catalog(
    product_id INT,
    product_name text,
    regular_price numeric,
    discount_price numeric

        CONSTRAINT valid_discount CHECK (
        regular_price > 0 AND
        discount_price > 0 AND
        discount_price < regular_price
        ) 
);

--Task 1.3
CREATE Table bookings(
    booking_id INT,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INT

        CONSTRAINT booking_valid CHECK(
          num_guests BETWEEN 1 AND 12 AND
          check_out_date > check_in_date  
        );
)

--Task 1.4
INSERT INTO employees (first_name, last_name, age, salary)
VALUES ('Kim', 'Anatoliy', 19, 5000),
       ('Kim', 'Timur', 19, 7000);

INSERT INTO products_catalog (product_id, product_name, regular_price, discount_price)
VALUES ('24B031848', 'Service', 1700, 700); 

INSERT INTO bookings (booking_id, check_in_date, check_out_date, num_guests)
VALUES ('24B031849', 03.05.2007 , 04.05.2007, 2); 

--Part 2
--Task 2.1

CREATE TABLE customers (

    customer_id SERIAL PRIMARY KEY NOT NULL,
    email text NOT NULL,
    phone text,
    registration_date date NOT NULL

);

--Task 2.2
CREATE TABLE inventory (

    item_id SERIAL PRIMARY KEY NOT NULL,
    item_name text NOT NULL,
    quantity int NOT NULL CHECK (quantity >= 0),
    unit_price numeric NOT NULL CHECK (unit_price > 0),
    last_updated timestamp NOT NULL

);

--Task 2.3

INSERT INTO inventory (item_name, quantity, unit_price, last_updated)
VALUES
  ('Laptop', 10, 1200.00, NOW()),
  ('Mouse', 50, 25.00, NOW());

INSERT INTO inventory (item_name, quantity, unit_price, last_updated)
VALUES (NULL, 10, 50.00, NOW());

INSERT INTO inventory (item_name, quantity, unit_price, last_updated)
VALUES ('Keyboard', NULL, 70.00, NOW());

INSERT INTO inventory (item_name, quantity, unit_price, last_updated)
VALUES ('Monitor', 5, NULL, NOW());

INSERT INTO inventory (item_name, quantity, unit_price, last_updated)
VALUES ('Desk', 3, 200.00, NULL);


--Part 3
--Tasl 3.1
CREATE TABLE users (

    user_id SERIAL PRIMERY KEY,
    username text UNIQUE,
    email text UNIQUE,
    created_at timestamp

);

--Task 3.2

CREATE TABLE course_enrollments (

    enrollment_id SERIAL PRIMARY KEY,
    student_id int,
    course_code text,
    semester text,
    CONSTRAINT unique_enrollment UNIQUE (student_id, course_code, semester)

);

--Task 3.3
ALTER TABLE users
ADD CONSTRAINT unique_username UNIQUE (username);
ALTER TABLE users
ADD CONSTRAINT unique_email UNIQUE (email);

INSERT INTO users (username, email)
VALUES ('john_doe', 'new_john@example.com');
--ERROR:  duplicate key value violates unique constraint "unique_username"

INSERT INTO users (username, email)
VALUES ('new_alice', 'alice@example.com');
-- ERROR:  duplicate key value violates unique constraint "unique_email"

--Part 4
--Task 4.1
CREATE TABLE departments (

    dept_id SERIAL PRIMARY KEY,
    dept_name text NOT NULL,
    location text

);

-- Insert valid data:
INSERT INTO departments (dept_id, dept_name, location)
VALUES
  (1, 'Database', 'Almaty'),
  (2, 'Finance', 'Shymkent'),
  (3, 'IT', 'Astana');

-- Try to insert duplicate dept_id (1 already exists)
INSERT INTO departments (dept_id, dept_name, location)
VALUES (1, 'Marketing', 'Almaty');

-- Try to insert NULL in dept_id
INSERT INTO departments (dept_id, dept_name, location)
VALUES (NULL, 'Legal', 'Rome');

--Task 4.2:

CREATE TABLE student_courses (

    student_id int,
    course_id int,
    enrollment_date date,
    grade text,
    PRIMARY KEY (student_id course_id)

);

--Task 4.3:

--The PRIMARY KEY uniquely identifies each record in a table and automatically enforces both uniqueness and NOT NULL. The UNIQUE constraint also ensures that all values in a column are distinct, but it allows NULL values and can be applied to multiple columns within the same table. A table can have only one primary key but can contain several unique constraints.
--A single-column primary key is used when one field (like id) can uniquely identify each record. A composite primary key is used when a combination of two or more columns together uniquely identifies a record — for example, (student_id, course_id) in a student enrollment table.
--A table can have only one PRIMARY KEY because it defines the main identity of each record and is used in relationships with other tables (foreign keys). However, it can have multiple UNIQUE constraints if there are several columns that must remain unique (e.g., email, username, or passport_number).

--Part 5
--Task 5.1:

CREATE TABLE employees_dept (

    emp_id INTEGER PRIMARY KEY,
    emp_name text NOT NULL,
    dept_id int REFERENCES departments(dept_id),
    hire_date date
);

INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date)
VALUES (123,'Vladislav','1',24-03-2015)

INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date)
VALUES (4, 'talgat', 10, '2024-03-15')

--Task 5.2:

CREATE TABLE authors (

    author_id SERIAL PRIMARY KEY,
    author_name text NOT NULL,
    country text

);

CREATE TABLE publishers (

    publisher_id SERIAL PRIMARY KEY,
    publisher_name text NOT NULL,
    city text

);

CREATE TABLE books (

    book_id SERIAL PRIMARY KEY,
    title text NOT NULL,
    author_id int REFERENCES authors(author_id),
    publisher_id int REFERENCES publishers(publisher_id),
    publication_year int,
    isbn text UNIQUE

);

INSERT INTO authors (author_name, country) 
VALUES
  ('George Orwell', 'United Kingdom'),
  ('Haruki Murakami', 'Japan'),
  ('Jane Austen', 'United Kingdom');

INSERT INTO publishers (publisher_name, city) 
VALUES
  ('Penguin Books', 'London'),
  ('Vintage', 'New York'),
  ('HarperCollins', 'London');

INSERT INTO books (title, author_id, publisher_id, publication_year, isbn) 
VALUES
  ('1984', 1, 1, 1949, '9780451524935'),
  ('Animal Farm', 1, 1, 1945, '9780451526342'),
  ('Norwegian Wood', 2, 2, 1987, '9780375704024'),
  ('Kafka on the Shore', 2, 2, 2002, '9781400079278'),
  ('Pride and Prejudice', 3, 3, 1813, '9780062870600');

--Task 5.3:

CREATE TABLE categories (

    category_id SERIAL PRIMARY KEY,
    category_name text NOT NULL

);

CREATE TABLE products_fk (

    product_id SERIAL PRIMARY KEY,
    product_name text NOT NULL,
    category_id int REFERENCES categories(category_id) ON DELETE RESTRICT

);


CREATE TABLE orders (

    order_id SERIAL PRIMARY KEY,
    order_date date NOT NULL

);

CREATE TABLE order_items (

    item_id SERIAL PRIMARY KEY,
    order_id int REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id int REFERENCES products_fk(product_id),
    quantity int CHECK (quantity > 0)

);

INSERT INTO categories (category_name) 
VALUES ('Laptops'), ('Mice');

INSERT INTO products_fk (product_name, category_id)
VALUES 
  ('MacBook Air', 1),
  ('ThinkPad X1', 1),
  ('Logitech M185', 2);

INSERT INTO orders (order_date)
VALUES ('2025-01-01'), ('2025-01-05');

INSERT INTO order_items (order_id, product_id, quantity)
VALUES 
  (1, 1, 1),
  (1, 2, 2),
  (2, 3, 3);

DELETE FROM categories WHERE category_id = 1;

DELETE FROM orders WHERE order_id = 1;

SELECT order_id, COUNT(*) AS items_left
FROM order_items
GROUP BY order_id
ORDER BY order_id;


--PART 6

--Task 6.1:

CREATE TABLE customers(
  customer_id SERIAL NOT NULL PRIMARY KEY,
  name text NOT NULL,
  email text NOT NULL UNIQUE,
  phone text NOT NULL UNIQUE,
  registration_date date NOT NULL default current_date
  );
  
CREATE TABLE products(
  product_id SERIAL NOT NULL PRIMARY KEY,
  name text NOT NULL UNIQUE,
  description text,
  price numeric(10,2) NOT NULL CHECK(price>=0),
  stock_quantity int CHECK(stock_quantity >= 0)
);

CREATE TABLE orders(
  order_id SERIAL NOT NULL PRIMARY KEY, 
  customer_id int REFERENCES customers(customer_id) ON DELETE RESTRICT, 
  order_date date default current_date, 
  total_amount numeric(10,2) NOT NULL default 0 CHECK(total_amount >= 0), 
  status text NOT NULL CHECK (status IN ('pending','paid','shipped','cancelled','completed'))
);

CREATE TABLE order_details(
  order_detail_id SERIAL NOT NULL PRIMARY KEY, 
  order_id int REFERENCES orders(order_id) ON DELETE CASCADE, 
  product_id int REFERENCES products(product_id) ON DELETE RESTRICT, 
  quantity int NOT NULL CHECK(quantity >= 0), 
  unit_price numeric(10,2) NOT NULL CHECK (unit_price >= 0),
  UNIQUE (order_id, product_id)
);