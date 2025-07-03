

SELECT * FROM coffee_shop_sales
-- text to date format 
UPDATE coffee_shop_sales
SET transaction_date = STR_TO_DATE(transaction_date, '%c/%e/%Y')

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;

-- text to time format
UPDATE coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s')

ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;

-- QUERIES

-- total sales for each month 
SELECT concat((round(SUM(unit_price * transaction_qty)))/1000, "K") AS Total_sales
FROM coffee_shop_sales
WHERE
MONTH(transaction_date) = 5 -- may

-- total items sold each month
SELECT count(transaction_id) as Total_orders
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 3 -- may 

-- month to month difference monetary and grow 

SELECT 
	MONTH(transaction_date) AS month,
    round(SUM(unit_price * transaction_qty)) AS total_sales,
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty),1)
    OVER(ORDER BY MONTH(transaction_date)))/LAG(SUM(unit_price * transaction_qty),1)
    OVER(ORDER BY MONTH(transaction_date)) *100 as month_increase_percentage 
FROM coffee_shop_sales
WHERE MONTH(transaction_date) IN (4,5)
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date)


-- month to month difference in number of orders and grow 
SELECT 
	MONTH(transaction_date) AS month,
    round(count(transaction_id)) AS total_orders,
    (count(transaction_id) - LAG(count(transaction_id),1)
    OVER(ORDER BY MONTH(transaction_date)))/LAG(count(transaction_id),1)
    OVER(ORDER BY MONTH(transaction_date)) *100 as month_increase_percentage 
FROM coffee_shop_sales
WHERE MONTH(transaction_date) IN (4,5)
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date)

-- month to month difference in quantity sold  and grow
 SELECT 
	MONTH(transaction_date) AS month,
    round(sum(transaction_qty)) AS total_quantity_sold,
    (sum(transaction_qty) - LAG(sum(transaction_qty),1)
    OVER(ORDER BY MONTH(transaction_date)))/LAG(sum(transaction_qty),1)
    OVER(ORDER BY MONTH(transaction_date)) *100 as month_increase_percentage 
FROM coffee_shop_sales
WHERE MONTH(transaction_date) IN (4,5)
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date)

-- dayly sales
SELECT 
	concat(round(SUM(unit_price * transaction_qty)/1000,1), 'K') AS total_sales, 
    concat(round(SUM(transaction_qty)/1000,1),'K') as Total_qty_sold, 
    concat(round(COUNT(transaction_id)/1000,1), 'K') as Total_orders
FROM coffee_shop_sales
WHERE transaction_date = '2023-5-18'

-- weekend and weekday analysis 

SELECT
	CASE WHEN dayofweek(transaction_date) IN (1,7) THEN 'Weekends'
    ELSE 'Weekdays'
    END AS day_type, 
    concat(round(SUM(unit_price * transaction_qty)/1000,1), 'K')  AS total_sales 
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 -- change to month
GROUP BY 
	CASE WHEN DAYOFWEEK(transaction_date) IN (1,7)  THEN 'Weekends'
    ELSE 'Weekdays'
    END

-- analysis by store location 

SELECT 
	store_location,
    concat(round(sum(unit_price * transaction_qty)/1000, 2), 'K') AS total_sales 
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY store_location 
ORDER BY SUM(unit_price * transaction_qty) DESC

-- daily sales analysis with average line 

SELECT 
	concat(round(AVG(total_sales)/1000, 1), 'K') AS avg_sales 
FROM
	(
    SELECT SUM(transaction_qty * unit_price) AS total_sales
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) = 5 
    GROUP BY transaction_date 
    ) AS internal_query
    
SELECT
	DAY(transaction_date) AS day_of_month 
    sum(unit_price * transaction_qty) as total_sales
FROM coffee_shop_sales
WHERE MONTH(trasanction_date) = 5
GROUP BY DAY(transaction_date)
ORDER BY DAY(transaction_date)


SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Equal to Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- for may 
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;
