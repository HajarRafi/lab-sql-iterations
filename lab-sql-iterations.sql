use sakila;

-- 1. Write a query to find what is the total business done by each store.

# inventory - rental - payment #

SELECT 
    i.store_id, SUM(p.amount) AS total_business
FROM
    sakila.inventory i
        JOIN
    sakila.rental r USING (inventory_id)
        JOIN
    sakila.payment p USING (rental_id)
GROUP BY i.store_id;

-- 2. Convert the previous query into a stored procedure.

delimiter //
CREATE PROCEDURE store_total_business_proc()
BEGIN
SELECT 
    i.store_id, SUM(p.amount) AS total_business
FROM
    sakila.inventory i
        JOIN
    sakila.rental r USING (inventory_id)
        JOIN
    sakila.payment p USING (rental_id)
GROUP BY i.store_id;
END; 
// delimiter ;

-- check
CALL store_total_business_proc;

-- 3. Convert the previous query into a stored procedure that takes the input for store_id 
-- and displays the total sales for that store.

DROP PROCEDURE IF EXISTS store_total_business_proc;

delimiter //
CREATE PROCEDURE store_total_business_proc(IN store INT)
BEGIN
SELECT 
    i.store_id, SUM(p.amount) AS total_business
FROM
    sakila.inventory i
        JOIN
    sakila.rental r USING (inventory_id)
        JOIN
    sakila.payment p USING (rental_id)
WHERE i.store_id COLLATE utf8mb4_general_ci = store  -- add condition with input variable
GROUP BY i.store_id;
END; 
// delimiter ;

CALL store_total_business_proc(2);

-- 3. Update the previous query. Declare a variable total_sales_value of float type, that will store 
-- the returned result (of the total sales amount for the store). Call the stored procedure and print the results.

DROP PROCEDURE IF EXISTS store_total_business_proc;

delimiter //
CREATE PROCEDURE store_total_business_proc(IN store INT)
BEGIN
DECLARE total_sales_value FLOAT DEFAULT 0.0;  -- declare new variable
SELECT total_business INTO total_sales_value  -- put into declared variable
FROM
    (SELECT 
    i.store_id, SUM(p.amount) AS total_business
FROM
    sakila.inventory i
        JOIN
    sakila.rental r USING (inventory_id)
        JOIN
    sakila.payment p USING (rental_id)
WHERE i.store_id COLLATE utf8mb4_general_ci = store
GROUP BY i.store_id) sub;
SELECT store, total_sales_value;  -- select both
SET total_sales_value = 0.0;
END; 
// delimiter ;

CALL store_total_business_proc(1);

-- 4. In the previous query, add another variable flag. If the total sales value for the store is over 30.000,
-- then label it as green_flag, otherwise label is as red_flag. Update the stored procedure that takes an input 
-- as the store_id and returns total sales value for that store and flag value.

DROP PROCEDURE IF EXISTS store_total_business_proc;

delimiter //
CREATE PROCEDURE store_total_business_proc(IN store INT, OUT label VARCHAR(20))  -- add otput value
BEGIN
DECLARE total_sales_value FLOAT DEFAULT 0.0;
DECLARE flag VARCHAR(20) DEFAULT "";  -- add new variable
SELECT 
    total_business
INTO total_sales_value FROM
    (SELECT 
        i.store_id, SUM(p.amount) AS total_business
    FROM
        sakila.inventory i
    JOIN sakila.rental r USING (inventory_id)
    JOIN sakila.payment p USING (rental_id)
    WHERE
        i.store_id COLLATE utf8mb4_general_ci = store
    GROUP BY i.store_id) sub;
SELECT store, total_sales_value; 
IF total_sales_value > 30000  -- create if statement
THEN SET flag = 'green_flag';
ELSE SET flag = 'red_flag';
END IF;
SELECT flag INTO label;
SELECT store, total_sales_value, label;  -- select all 3 columns
END; 
// delimiter ;

CALL store_total_business_proc(1, @x);





