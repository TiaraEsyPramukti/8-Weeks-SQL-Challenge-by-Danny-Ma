/* 
A. Customer Journey
Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!
*/
USE foodie_fi;

WITH journey AS(
	SELECT 
		s.*,
		p.plan_name
	FROM subscriptions AS s
	LEFT JOIN plans AS p
	ON s.plan_id = p.plan_id
	WHERE s.customer_id BETWEEN 1 AND 8)

SELECT plan_id, plan_name, count(1)
FROM journey
GROUP BY plan_id
ORDER BY plan_id;

/*
Based on each count of plan from 8 customers, the number of trial plan is 8. It means all customer’s onboarding journey begin with trial plan.
Then, it varies to other plans.
*/

/*
B. Data Analysis Questions
*/

-- 1. How many customers has Foodie-Fi ever had?
SELECT (count(DISTINCT customer_id))
FROM subscriptions;

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value?
/* (check the range of start_date first to decide the grouping should be based on month only or month and year) */
SELECT MIN(start_date), MAX(start_date)
FROM subscriptions;

SELECT
	MONTHNAME(start_date) AS month,
    COUNT(plan_id) AS count_of_event
FROM subscriptions
WHERE plan_id = 0
GROUP BY YEAR(start_date), MONTH(start_date)
ORDER BY YEAR(start_date), MONTH(start_date);

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT
	plan_name,
    COUNT(s.plan_id) AS count_of_events
FROM subscriptions AS s
LEFT JOIN plans AS p
ON s.plan_id = p.plan_id
WHERE YEAR(start_date) > 2020
GROUP BY plan_name;

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT
	COUNT(*) AS number_of_churned_customer,
    ROUND(
		COUNT(*)/(SELECT COUNT(DISTINCT(customer_id))
        FROM subscriptions) * 100, 1)
        AS percentage_of_churned_customer
FROM subscriptions
WHERE plan_id = 4;

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
/*
SELECT s.customer_id, plan_id, start_date
FROM subscriptions AS s
LEFT JOIN
	(SELECT customer_id, MIN(start_date) as min_date
	FROM subscriptions
    GROUP BY customer_id) AS s1
ON (s.customer_id = s1.customer_id)
WHERE start_date > min_date;
*/

WITH summary AS (
	SELECT
		s.customer_id, s.plan_id, s.start_date,
		ROW_NUMBER()
			OVER(PARTITION BY s.customer_id
				ORDER BY s.start_date) AS ranking
	FROM subscriptions s)
    
SELECT COUNT(customer_id) AS number_of_churn_after_trial
FROM summary
WHERE ranking = 2 AND plan_id = 4;
 
-- 6. What is the number and percentage of customer plans after their initial free trial?
WITH summary AS (
	SELECT
		s.customer_id, s.plan_id, s.start_date, p.plan_name,
		ROW_NUMBER()
			OVER(PARTITION BY s.customer_id
				ORDER BY s.start_date) AS ranking
	FROM subscriptions s
    LEFT JOIN plans p
    ON s.plan_id = p.plan_id)
    
SELECT
	plan_name,
	COUNT(customer_id) AS number_of_customer,
    ROUND(
		COUNT(customer_id)/(SELECT COUNT(DISTINCT customer_id) FROM summary) * 100, 2)
        AS percentage
FROM summary
WHERE ranking = 2
GROUP BY plan_name
ORDER BY plan_id;

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?


-- 8. How many customers have upgraded to an annual plan in 2020?
SELECT 
	COUNT(DISTINCT customer_id) AS number_of_customer_annual_plan
FROM subscriptions s
LEFT JOIN plans p
ON s.plan_id = p.plan_id
WHERE 
	(YEAR(start_date) = 2020 AND 
    plan_name LIKE '%annual%');

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
WITH trial AS(
	SELECT
		customer_id, start_date AS trial_date
    FROM subscriptions
    WHERE plan_id = 0),
    
    annual AS(
    SELECT
		customer_id, start_date AS annual_date
    FROM subscriptions
    WHERE plan_id = 3)

SELECT
	AVG(DATEDIFF(annual_date, trial_date)) AS average_days_trial_to_annual
FROM trial t
JOIN annual a
ON t.customer_id = a.customer_id;

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
