/*
	Pizza Metrics
*/
-- 1. How many pizzas were ordered?
SELECT
	COUNT(order_id) AS num_pizza_ordered
FROM customer_orders;
-- there were 14 pizzas ordered


-- 2. How many unique customer orders were made?
SELECT
	COUNT(DISTINCT order_id) AS num_unique_customer_orders
FROM customer_orders;
-- there were 10 customer orders made


-- 3. How many successful orders were delivered by each runner?
WITH runner_orders_clean AS(
	SELECT
		order_id,
		runner_id,
        CAST(CASE WHEN pickup_time IN('null','','NaN') THEN NULL ELSE pickup_time END AS DATETIME) AS pickup_time,
        CAST(CASE WHEN substring(distance, 1, 4) regexp '[0-9.]' = 'null' THEN NULL
				ELSE substring(distance, 1, 4) END AS DEC(7,2)) AS distance,
		CAST(CASE WHEN substring(duration, 1, 4) regexp '[0-9.]' = 'null' THEN NULL
				ELSE substring(duration, 1, 4) END AS DEC(7,2)) AS duration,
		CASE WHEN cancellation LIKE '%cancel%' THEN 'cancel' ELSE 'no' END AS cancellation
	FROM runner_orders)

SELECT
	runner_id,
	COUNT(cancellation) AS delivered
FROM runner_orders_clean
WHERE cancellation = 'no'
GROUP BY runner_id;
-- there were 4 by runner_id 1, 3 by runner_id 2, 1 by runner_id 3 successful orders delivered


-- 4. How many of each type of pizza was delivered?
WITH runner_orders_clean AS(
	SELECT
		order_id,
		runner_id,
        CAST(CASE WHEN pickup_time IN('null','','NaN') THEN NULL ELSE pickup_time END AS DATETIME) AS pickup_time,
        CAST(CASE WHEN substring(distance, 1, 4) regexp '[0-9.]' = 'null' THEN NULL
				ELSE substring(distance, 1, 4) END AS DEC(7,2)) AS distance,
		CAST(CASE WHEN substring(duration, 1, 4) regexp '[0-9.]' = 'null' THEN NULL
				ELSE substring(duration, 1, 4) END AS DEC(7,2)) AS duration,
		CASE WHEN cancellation LIKE '%cancel%' THEN 'cancel' ELSE 'no' END AS cancellation
	FROM runner_orders)

SELECT
	pizza_id,
	COUNT(pizza_id) AS delivered
FROM customer_orders
JOIN runner_orders_clean
ON customer_orders.order_id = runner_orders_clean.order_id
WHERE cancellation = 'no'
GROUP BY pizza_id;
-- there were 9 pizzas type 1, 3 pizzas type 2 delivered


-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT
	customer_id,
	CAST(pizza_name AS CHAR) AS pizza_name,
	COUNT(CAST(pizza_name AS CHAR)) AS ordered
FROM customer_orders
JOIN pizza_names
ON customer_orders.pizza_id = pizza_names.pizza_id
GROUP BY CAST(pizza_name AS CHAR), customer_id;  


-- 6. What was the maximum number of pizzas delivered in a single order?
WITH runner_orders_clean AS(
	SELECT
		order_id,
		runner_id,
        CAST(CASE WHEN pickup_time IN('null','','NaN') THEN NULL ELSE pickup_time END AS DATETIME) AS pickup_time,
        CAST(CASE WHEN substring(distance, 1, 4) regexp '[0-9.]' = 'null' THEN NULL
				ELSE substring(distance, 1, 4) END AS DEC(7,2)) AS distance,
		CAST(CASE WHEN substring(duration, 1, 4) regexp '[0-9.]' = 'null' THEN NULL
				ELSE substring(duration, 1, 4) END AS DEC(7,2)) AS duration,
		CASE WHEN cancellation LIKE '%cancel%' THEN 'cancel' ELSE 'no' END AS cancellation
	FROM runner_orders)

SELECT
	customer_orders.order_id,
	COUNT(customer_orders.order_id) AS num_pizza_delivered
FROM customer_orders
JOIN runner_orders_clean
ON customer_orders.order_id = runner_orders_clean.order_id
WHERE cancellation = 'no'
GROUP BY customer_orders.order_id;


-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?


-- 8. How many pizzas were delivered that had both exclusions and extras?
WITH customer_orders_clean AS(
	SELECT
		order_id,
		customer_id,
		pizza_id,
		CASE WHEN exclusions IN('null','','NaN') THEN NULL ELSE exclusions END AS exclusions,
		CASE WHEN extras IN('null','','NaN') THEN NULL ELSE extras END AS extras,
		order_time
	FROM customer_orders),
	
	runner_orders_clean AS(
	SELECT
		order_id,
		runner_id,
        CAST(CASE WHEN pickup_time IN('null','','NaN') THEN NULL ELSE pickup_time END AS DATETIME) AS pickup_time,
        CAST(CASE WHEN substring(distance, 1, 4) regexp '[0-9.]' = 'null' THEN NULL
				ELSE substring(distance, 1, 4) END AS DEC(7,2)) AS distance,
		CAST(CASE WHEN substring(duration, 1, 4) regexp '[0-9.]' = 'null' THEN NULL
				ELSE substring(duration, 1, 4) END AS DEC(7,2)) AS duration,
		CASE WHEN cancellation LIKE '%cancel%' THEN 'cancel' ELSE 'no' END AS cancellation
	FROM runner_orders)

SELECT
	COUNT(customer_orders_clean.order_id) AS exclusions_extras_delivered
FROM customer_orders_clean
JOIN runner_orders_clean
ON customer_orders_clean.order_id = runner_orders_clean.order_id
WHERE cancellation = 'no' AND (exclusions IS NOT NULL AND extras IS NOT NULL);


-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT
	DATEPART(hour, order_time) AS order_hour,
	COUNT(pizza_id) AS vol_pizza_ordered
FROM customer_orders
GROUP BY DATEPART(hour, order_time);


-- 10. What was the volume of orders for each day of the week?
SELECT
	DATEPART(week, order_time) AS order_week,
	DATEPART(day, order_time) AS order_day,
	COUNT(order_id) AS vol_order
FROM customer_orders
GROUP BY DATEPART(week, order_time), DATEPART(day, order_time);


-- clean data set
/*
WITH customer_orders_clean AS(
	SELECT
		order_id,
		customer_id,
		pizza_id,
		CASE WHEN exclusions IN('null','','NaN') THEN NULL ELSE exclusions END AS exclusions,
		CASE WHEN extras IN('null','','NaN') THEN NULL ELSE extras END AS extras,
		order_time
	FROM customer_orders),
	
	runner_orders_clean AS(
	SELECT
		order_id,
		runner_id,
        CAST(CASE WHEN pickup_time IN('null','','NaN') THEN NULL ELSE pickup_time END AS DATETIME) AS pickup_time,
        CAST(CASE WHEN substring(distance, 1, 4) regexp '[0-9.]' = 'null' THEN NULL
				ELSE substring(distance, 1, 4) END AS DEC(7,2)) AS distance,
		CAST(CASE WHEN substring(duration, 1, 4) regexp '[0-9.]' = 'null' THEN NULL
				ELSE substring(duration, 1, 4) END AS DEC(7,2)) AS duration,
		CASE WHEN cancellation LIKE '%cancel%' THEN 'cancel' ELSE 'no' END AS cancellation
	FROM runner_orders)
*/
-- clean dataset for customer_orders and runner_orders