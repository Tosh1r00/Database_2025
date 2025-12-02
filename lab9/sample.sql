-- Task 1
CREATE FUNCTION calculate_discount 
    (original_orice,discount_percent)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN
original_orice - ((original_orice * discount_percent) / 100);
END;
$$;

--Test for task 1
SELECT calculate_discount (100,15);
SELECT calculate_discount (250.50, 20);

--Task 2 Working with OUT Parameters
CREATE FUNCTION film_status(
    p_rating VARCHAR;
    OUT total_films NUMERIC;
    OUT avg_rental_rate NUMERIC;
)
LANGUAGE plpgsql
AS $$
 --COUNT films
SELECT COUNT(*)
INTO total_films
FROM film
WHERE rating = p.rating;

--Calculacte avg
SELECT AVG(*)
INTO avg_rental_rate
FROM film
WHERE rating = p.rating;

END;
$$

--TEST 
SELECT * FROM film_stats('PG');
SELECT * FROM film_stats('R');

--Task 3. Functuion Returning a Table
CREATE FUNCTION get_customer_rentals (p_customer_id INTEGER)
RETURNS TABLE (
    rental_date DATE,
    film_title VARCHAR,
    return_date DATE
)

LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.rental_date,
        f.title AS film_title,
        r.return_date
    FROM rental RIGHT JOIN
    JOIN inventory i on r.inventory_id = i.inventory_id
    JOIN film f on i.film_id = f.film_id
    WHERE r.customer_id = p_customer_id
    ORDER BY r.rental_date;
END;
$$;

--TEST 
SELECT * FROM get_customer_rentals(1);
SELECT * FROM get_customer_rentals(5) LIMIT 5;

--Task 4 Function Overloading
CREATE FUNCTION OR REPLACE search_films(
    p_title_pattern VARCHAR
)
RETURNS TABLE (
    title VARCHAR,
    release_year INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        f.title,
        f.release_year
    FROM film f
    WHERE f.title LIKE p_title_pattern
    ORDER BY f.title;
END;
$$;

CREATE FUNCTION OR REPLACE search_films(
    p_title_pattern VARCHAR,
    p_rating VARCHAR
)
RETURNS TABLE (
    title VARCHAR,
    release_year INTEGER,
    rating VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        f.title,
        f.release_year,
        f.rating
    FROM film f
    WHERE f.title LIKE p_title_pattern
      AND f.rating = p_rating
    ORDER BY f.title;
END;
$$;
