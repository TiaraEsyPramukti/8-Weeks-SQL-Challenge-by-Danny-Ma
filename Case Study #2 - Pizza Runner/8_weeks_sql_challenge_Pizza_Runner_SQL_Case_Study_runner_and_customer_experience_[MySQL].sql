/*
	Runner and Customer Experience
*/
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT
	WEEK(registration_date)+1 AS registration_week,
	COUNT(runner_id) num_runner_registered
FROM runners
GROUP BY WEEK(registration_date);


-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH runner_orders_clean AS(SELECT
	order_id,
	runner_id,
	CAST(CASE WHEN pickup_time IN('null','','NaN') THEN NULL ELSE pickup_time END AS DATETIME) AS pickup_time
FROM runner_orders)

SELECT
	runner_id,
    (AVG(TIME_TO_SEC(TIMEDIFF(pickup_time, order_time))))/60 AS average_time_in_minutes
    /*
    SEC_TO_TIME(AVG(TIME_TO_SEC(TIMEDIFF(pickup_time, order_time)))) AS average_time_in_minutes
    */
FROM runner_orders_clean
JOIN customer_orders
ON runner_orders_clean.order_id = customer_orders.order_id
GROUP BY runner_id;


-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH runner_orders_clean AS(SELECT
	order_id,
	CAST(CASE WHEN pickup_time IN('null','','NaN') THEN NULL ELSE pickup_time END AS DATETIME) AS pickup_time
FROM runner_orders)

SELECT
	customer_orders.order_id,
    COUNT(customer_orders.order_id) AS number_of_pizza,
    (AVG(TIME_TO_SEC(TIMEDIFF(pickup_time, order_time))))/60 AS average_time_in_minutes
    /*
    SEC_TO_TIME(AVG(TIME_TO_SEC(TIMEDIFF(pickup_time, order_time)))) AS average_time_in_minutes
    */
FROM runner_orders_clean
JOIN customer_orders
ON runner_orders_clean.order_id = customer_orders.order_id
GROUP BY customer_orders.order_id;


-- 4. What was the average distance travelled for each customer?
WITH runner_orders_clean AS(
	SELECT
		order_id,
		CAST(CASE WHEN substring(distance, 1, 4) regexp '[0-9.]' = 'null' THEN NULL
				ELSE substring(distance, 1, 4) END AS DEC(7,2)) AS distance
		FROM runner_orders)
        
SELECT
	customer_id,
    AVG(distance) AS average_distance_in_km
FROM customer_orders
JOIN runner_orders_clean
ON customer_orders.order_id = runner_orders_clean.order_id
GROUP BY customer_id;


-- 5. What was the difference between the longest and shortest delivery times for all orders?
WITH runner_orders_clean AS(
	SELECT
		order_id,
		CAST(CASE WHEN substring(duration, 1, 4) regexp '[0-9.]' = 'null' THEN NULL
				ELSE substring(duration, 1, 4) END AS DEC(7,2)) AS duration
	FROM runner_orders)
    
    SELECT 
		MAX(duration)-MIN(duration) AS difference_time
	FROM runner_orders_clean;


-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
WITH runner_orders_clean AS(
	SELECT
		order_id,
		runner_id,
        CAST(CASE WHEN substring(distance, 1, 4) regexp '[0-9.]' = 'null' THEN NULL
				ELSE substring(distance, 1, 4) END AS DEC(7,2)) AS distance,
		CAST(CASE WHEN substring(duration, 1, 4) regexp '[0-9.]' = 'null' THEN NULL
				ELSE substring(duration, 1, 4) END AS DEC(7,2)) AS duration
	FROM runner_orders)
    
    SELECT 
		runner_id,
        order_id,
        AVG(distance/duration) AS average_speed
	FROM runner_orders_clean
    GROUP BY runner_id, order_id
    ORDER BY runner_id;


-- 7. What is the successful delivery percentage for each runner?
WITH runner_orders_clean AS(
	SELECT
		runner_id,
        CASE WHEN cancellation LIKE '%cancel%' THEN 'cancel' ELSE 'no' END AS cancellation
	FROM runner_orders)
    
SELECT
	runner_id,
	COUNT(cancellation)/(SELECT COUNT(cancellation) FROM runner_orders_clean)*100 AS percentage_successful_delivery
FROM runner_orders_clean
WHERE cancellation = 'no'
GROUP BY runner_id;