/* --------------------
   Danny's Diner SQL Case Study
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
SELECT
	customer_id,
	SUM(price) AS total_amount
FROM sales
JOIN menu
ON sales.product_id = menu.product_id
GROUP BY customer_id;


-- 2. How many days has each customer visited the restaurant?
SELECT
	customer_id,
	COUNT(DISTINCT order_date) n_days_visited
FROM sales
GROUP BY customer_id;


-- 3. What was the first item from the menu purchased by each customer?
SELECT
	DISTINCT customer_id,
	product_name
FROM sales
JOIN menu
ON sales.product_id = menu.product_id
WHERE order_date IN (SELECT
						MIN(order_date)
					FROM sales
					GROUP BY customer_id);


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
WITH purchase AS (
	SELECT
		product_id,
		COUNT(sales.product_id) AS amount
	FROM sales
	GROUP BY product_id)

SELECT
	product_name,
	amount
FROM purchase
JOIN menu
ON purchase.product_id = menu.product_id
WHERE amount = (SELECT MAX(amount) FROM purchase);

/* OR */
WITH purchase AS (
	SELECT
		product_name,
		COUNT(sales.product_id) AS amount
	FROM sales
	JOIN menu
	ON sales.product_id = menu.product_id
	GROUP BY product_name)

SELECT
	product_name,
	amount
FROM purchase
WHERE amount = (SELECT MAX(amount) FROM purchase);


-- 5. Which item was the most popular for each customer?
WITH purchase AS (
	SELECT
		customer_id,
		product_name,
		COUNT(sales.product_id) AS amount
	FROM sales
	JOIN menu
	ON sales.product_id = menu.product_id
	GROUP BY product_name, customer_id)

SELECT
	customer_id,
	product_name,
	amount
FROM purchase AS p1
WHERE amount IN (SELECT MAX(amount)
				FROM purchase AS p2
				GROUP BY customer_id
				HAVING p1.customer_id = p2.customer_id);


-- 6. Which item was purchased first by the customer after they became a member?
WITH purchase AS (
	SELECT
		sales.customer_id,
		product_name,
		order_date,
		join_date
	FROM sales
	JOIN members ON sales.customer_id = members.customer_id
	JOIN menu ON sales.product_id = menu.product_id
	WHERE order_date >= join_date)

SELECT
	customer_id,
	product_name,
	order_date,
	join_date
FROM purchase p1
WHERE order_date IN (SELECT MIN(order_date)
					FROM purchase p2
					GROUP BY customer_id
					HAVING p1.customer_id = p2.customer_id);


-- 7. Which item was purchased just before the customer became a member?
WITH purchase AS (
	SELECT
		sales.customer_id,
		product_name,
		order_date,
		join_date
	FROM sales
	JOIN members ON sales.customer_id = members.customer_id
	JOIN menu ON sales.product_id = menu.product_id
	WHERE order_date < join_date)

SELECT
	customer_id,
	product_name,
	order_date,
	join_date
FROM purchase p1
WHERE order_date IN (SELECT MAX(order_date)
					FROM purchase p2
					GROUP BY customer_id
					HAVING p1.customer_id = p2.customer_id);


-- 8. What is the total items and amount spent for each member before they became a member?
WITH purchase AS (
	SELECT
		sales.customer_id,
		product_name,
		order_date,
		join_date,
		price
	FROM sales
	JOIN members ON sales.customer_id = members.customer_id
	JOIN menu ON sales.product_id = menu.product_id
	WHERE order_date < join_date)

SELECT
	customer_id,
	COUNT(product_name) AS num_of_item,
	SUM(price) AS amount_spent
FROM purchase
GROUP BY customer_id;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT
	customer_id,
	SUM(CASE WHEN product_name = 'sushi' THEN 20 ELSE 10 END) AS point
FROM sales
JOIN menu
ON sales.product_id = menu.product_id
GROUP BY customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH point AS (
	SELECT
		sales.customer_id,
		order_date,
		product_name,
		join_date
	FROM sales
	JOIN menu ON sales.product_id = menu.product_id
	FULL JOIN members ON sales.customer_id = members.customer_id
	WHERE sales.customer_id <> 'C')
	
SELECT
	customer_id,
	SUM(CASE
		WHEN DATEPART(week, order_date) = DATEPART(week, join_date) THEN 20
		WHEN (DATEPART(week, order_date) <> DATEPART(week, join_date)) AND product_name = 'sushi' THEN 20
		WHEN (DATEPART(week, order_date) <> DATEPART(week, join_date)) AND product_name <> 'sushi' THEN 10 END) AS point
FROM point
WHERE order_date < '2021-02-01'
GROUP BY customer_id;

/* customer C included */
/*WITH point AS (
	SELECT
		sales.customer_id,
		order_date,
		product_name,
		join_date
	FROM sales
	JOIN menu ON sales.product_id = menu.product_id
	FULL JOIN members ON sales.customer_id = members.customer_id)
	
SELECT
	customer_id,
	SUM(CASE
		WHEN join_date IS NOT NULL AND DATEPART(week, order_date) = DATEPART(week, join_date) THEN 20
		WHEN (join_date IS NULL OR DATEPART(week, order_date) <> DATEPART(week, join_date)) AND product_name = 'sushi' THEN 20
		WHEN (join_date IS NULL OR DATEPART(week, order_date) <> DATEPART(week, join_date)) AND product_name <> 'sushi' THEN 10 END) AS point
FROM point
WHERE order_date < '2021-02-01'
GROUP BY customer_id;

/* OR */

WITH point AS (
	SELECT
		sales.customer_id,
		order_date,
		product_name,
		join_date
	FROM sales
	JOIN menu ON sales.product_id = menu.product_id
	FULL JOIN members ON sales.customer_id = members.customer_id)
	
SELECT
	customer_id,
	SUM(CASE
		WHEN join_date IS NOT NULL AND DATEPART(week, order_date) = DATEPART(week, join_date) THEN 20
		WHEN (join_date IS NULL OR join_date IS NOT NULL) AND product_name = 'sushi' THEN 20 ELSE 10 END) AS point
FROM point
WHERE order_date < '2021-02-01'WHERE order_date < '2021-02-01'
GROUP BY customer_id;*/


/*-- Example Query:
SELECT
  	product_id,
    product_name,
    price
FROM menu
ORDER BY price DESC
LIMIT 5;*/