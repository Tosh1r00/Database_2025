CREATE TABLE accounts (
                          id SERIAL PRIMARY KEY,
                          name VARCHAR(100) NOT NULL,
                          balance DECIMAL(10, 2) DEFAULT 0.00
);
CREATE TABLE products (
                          id SERIAL PRIMARY KEY,
                          shop VARCHAR(100) NOT NULL,
                          product VARCHAR(100) NOT NULL,
                          price DECIMAL(10, 2) NOT NULL
);
-- Insert test data
INSERT INTO accounts (name, balance) VALUES
                                         ('Alice', 1000.00),
                                         ('Bob', 500.00),
                                         ('Wally', 750.00);

INSERT INTO products (shop, product, price) VALUES
                                         ('Joe''s Shop ','Coke', 2.5),
                                         ('Joe''s Shop ', 'Pepsi',3),
                                         ('Joe''s Shop ','Fanta', 3.5);
--Task 1
BEGIN;
UPDATE accounts SET balance = balance - 200.00 WHERE name =
                                                     'Alice';
UPDATE accounts SET balance = balance + 200.00 WHERE name =
                                                     'Bob';
COMMIT;

/*
1.1 Alice = 800; Bob = 700
1.2 Atomicity
1.3 Atomicity - Either the whole process is done or none is. All operations succeed or all fail
*/

--Task 2
BEGIN;
INSERT INTO products (shop, product, price) VALUES ('Joe''s
Shop', 'Sprite', 2.00);
SAVEPOINT sp1;
UPDATE products SET price = 5.00 WHERE product = 'Sprite';
SAVEPOINT sp2;
DELETE FROM products WHERE product = 'Sprite';
ROLLBACK TO sp1;
COMMIT;

--2.1 Yes
-- 2.2 2.00
-- 2.3 BC Sprite has changed the price but after Rolling back to sp1, it changed back to original price ROLLBACK TO sp1;

--Task 3
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT MAX(price) FROM products WHERE shop = 'Joe''s Shop';
-- Query A
-- (T2 executes here)
Transaction T2 (executes between Query A and Query B of T1):
BEGIN;
INSERT INTO products (shop, product, price) VALUES ('Joe''s
Shop', 'Water', 10.00);
COMMIT;

SELECT MAX(price) FROM products WHERE shop = 'Joe''s Shop';
-- Query B
COMMIT;


/*
3.1 Fanta - 3.5
3.2 Water - 10.00
3.3 Fanta - 3.5
3.4 Non-Repeatable Read: "Same row read twice returns different values."
*/

