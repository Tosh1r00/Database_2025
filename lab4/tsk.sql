CREATE TABLE flights (
    flight_id INT PRIMARY KEY,
    flight_number VARCHAR(10),
    origin VARCHAR(50),
    destination VARCHAR(50),
    departure_time TIMESTAMP,
    arrival_time TIMESTAMP,
    aircraft_type VARCHAR(50),
    status VARCHAR(20),
    ticket_price NUMERIC(8,2)
);

CREATE TABLE passengers(
    passenger_id INT PRIMARY KEY,
    passenger_name VARCHAR (50),
    nationality VARCHAR(50),
    passport_number INT,
    frequent_flyer_status VARCHAR(30),
);
CREATE TABLE bookings (
    booking_id INT PRIMARY KEY,
    passenger_id INT,
    flight_id INT,
    booking_date CURRENT_DATE,
    seat_number VARCHAR(10),
    baggage_weight NUMERIC(5,2)
);

--Part A
--T A.1
SELECT LOWER (flight_numbers) as flnum FROM flights;
SELECT (origin || '->' || destination) as flight_dest FROM flights;
SELECT aircraft_type || ' Aircraft' AS aircr;

--T A.2
SELECT * FROM flights WHERE destination LIKE 'New%' OR  LIKE 'Los%'

--T A.3
ALTER TABLE passengers
ADD passenger_category VARCHAR(20);

UPDATE passengers SET passenger_category = 
    CASE 
    WHEN frequent_flyer_status = 'Silver' THEN 'Regular Member'
    WHEN frequent_flyer_status IN ('Gold', 'Platinum') THEN 'Elite Member'
    ELSE 'Standard'
    END;

--Part B
--T2.1
SELECT flight_number, departure_time, arrival_time,
EXTRACT(EPOCH FROM (arrival_time - departure_time)) / 3600 AS flight_duration_hours
FROM flights;

--T.2
SELECT * FROM bookings WHERE booking_date - 30 as BDAY;  

--T.3
SELECT HOUR(departure_time) AS departure_hour FROM flights WHERE HOUR(departure_time) < 12
--Part C
--T.1
SELECT b.baggage_weight, COALESCE(SUM(b.baggage_weight), 0) AS total_weight FROM baggage b;

--T.2
SELECT * FROM passengers WHERE baggage_weight BETWEEN 15 AND 25 AND WHERE frequent_flyer_status NOT NULL;

--T.3
--не понял

--T.4
--не понял

--PART D
--Task D1:
SELECT flight_id, COUNT(*) AS passenger_count
FROM bookings
GROUP BY flight_id;

--Task D2:
SELECT nationality, AVG(baggage_weight) AS acg_bw, JOIN bookings ON passengers.passenger_id = bookings.passenger_id
GROUP BY nationality
HAVING AVG(baggage_weight) > 18;

--Task D3:
SELECT 
    aircraft_type, MIN(ticket_price) AS min_price, MAX(ticket_price) AS max_price
FROM flights
GROUP BY aircraft_type;


--Task D4:
SELECT 
    destination, SUM(ticket_price) AS total_revenue FROM flights GROUP BY destination;

