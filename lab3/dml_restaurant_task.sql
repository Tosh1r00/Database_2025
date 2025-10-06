CREATE TABLE menu_items(
    items_id SERIAL PRIMARY KEY,
    item_name VARCHAR,
    category VARCHAR,
    base_price INT,
    is_available BOOLEAN,
    prep_time_minutes INT;
)
CREATE TABLE customer_orders (
    order_id SERIAL PRIMARY KEY,
    customer_name VARCHAR,
    order_date DATE,
    total_amount FLOAT,
    payment_status BOOLEAN,
    table_namber INT;
)
CREATE TABLE order_details(
    detail_id SERIAL PRIMARY KEY,
    order_id SERIAL PRIMARY KEY,
    item_id SERIAL PRIMARY KEY,
    quantity INT,
    special_instructions VARCHAR;
)

--Part A
INSERT INTO menu_items (item_name, category, base_price, is_available, prep_time_minutes)
VALUES ('Chef Special Burger', 'Main course', (12.00*1,25)::int,true,20)

INSERT INTO customer_orders (customer_name,order_date,total_amount,payment_status,table_namber)
VALUES ('John Smith',CURRENT_DATE,45.50,'PAID',5; 
'Mary Johnson', CURRENT_DATE, 32.20, 'Pending',8; 
'Bob Wilson', CURRENT_DATE, 28.75,'PAID',3)

INSERT INTO customer_orders(customer_name,order_date,total_amount,payment_status,table_namber)
VALUES ('Walk in customer', CURRENT_DATE, 'DEFAULT', NULL)

--PART B
UPDATE menu_items SET base_price = (salary * 1,08)::int WHERE category = 'Appetizers';

UPDATE menu_items SET category = CASE
    WHEN base_price > 20 THEN 'Premium'
    WHEN base_price BETWEEN 10 and 20 THEN 'Standart'
    ELSE 'BUDGET'
END;

UPDATE menu_items SET is_available = false
FROM (
    SELECT item_id	FROM order_details	WHERE	quantity	>	10
) 

--Part C
DELETE * FROM menu_items WHERE is_available	= false	AND	base_price	<	5.00;
DELETE * FROM customer_orders WHERE order_date	< '2024-01-01' AND payment_status	
= 'Cancelled';

DELETE FROM order_details d 
WHERE NOT EXISTS (
  SELECT 1
  FROM order_details e
  WHERE e.order_id = d.order_id
);

--PART D
UPDATE menu_items
SET prep_time_minutes = NULL
WHERE category IS NULL;
RETURNING *;

INSERT INTO customer_orders (total_amount)
values (NULL)
RETURNING order_id, customer_name;
