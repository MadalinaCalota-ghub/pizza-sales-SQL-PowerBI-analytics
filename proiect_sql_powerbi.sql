SELECT *
FROM pizza_sales;

-- 1. Total Revenue:

SELECT Round(SUM(ps.total_price),2) AS Total_Revenue
FROM pizza_sales ps;

-- 2. Average Order Value


SELECT COUNT(Distinct ps.order_id) AS Total_noOrders
FROM pizza_sales ps;

SELECT SUM(ps.total_price) / COUNT(Distinct ps.order_id) AS Avg_Order_Value
FROM pizza_sales ps;

-- KPI v2 CTE

WITH calcule AS(
	SELECT SUM(ps.total_price) AS Total_Revenue, 
			 COUNT(Distinct ps.order_id) AS Total_noOrders,
	  	  	 SUM(ps.quantity) AS Total_pizzas_sold
	FROM pizza_sales ps)
	
SELECT 	Total_Revenue,
			Total_noOrders,
			Total_pizzas_sold,
			Total_Revenue / Total_noOrders AS Avg_Order_Value,
			ROUND((Total_pizzas_sold / Total_noOrders),2) AS Avg_Pizzas_Per_Order
FROM calcule c;

-- total pizzas sold - orders by days

SELECT 
    DAYNAME(STR_TO_DATE(ps.order_date, '%d/%m/%Y')) AS order_day,
    COUNT(DISTINCT ps.order_id) AS total_orders
FROM pizza_sales ps
GROUP BY DAYNAME(STR_TO_DATE(ps.order_date, '%d/%m/%Y'))
ORDER BY total_orders DESC;

-- sortat dupa nr de comenzi cel mai mare -- orders by month

SELECT 
    MONTHNAME(STR_TO_DATE(ps.order_date,'%d/%m/%Y')) AS order_month,
    COUNT(DISTINCT ps.order_id) AS total_orders
FROM pizza_sales ps
GROUP BY MONTHNAME(STR_TO_DATE(ps.order_date,'%d/%m/%Y'))
ORDER BY total_orders DESC;

-- sortat dupa prima luna a anului -- pana la ultima luna
SELECT 
    MONTHNAME(STR_TO_DATE(ps.order_date, '%d/%m/%Y')) AS order_month,
    COUNT(DISTINCT ps.order_id) AS total_orders
FROM pizza_sales ps
GROUP BY 
    MONTHNAME(STR_TO_DATE(ps.order_date, '%d/%m/%Y')),
    MONTH(STR_TO_DATE(ps.order_date, '%d/%m/%Y'))
ORDER BY MONTH(STR_TO_DATE(ps.order_date, '%d/%m/%Y')) ASC;

/*----------------------------------------------------------------- de verificare------------------------------*/

SELECT order_date 
FROM pizza_sales 
WHERE CAST(SUBSTRING_INDEX(order_date, '/', 1) AS UNSIGNED) > 12 
LIMIT 5;

-- ----------------------------------------------------


-- percentage of sales by pizza categories

WITH sales_per_category AS(
		SELECT ps.pizza_category, SUM(ps.total_price) AS total_revenue_categ
		FROM pizza_sales ps
		GROUP BY ps.pizza_category),
		
		total_gen AS(
		SELECT SUM(ps.total_price) AS total_revenue
		FROM pizza_sales ps)

SELECT spc.pizza_category, 
		 Concat(ROUND((total_revenue_categ / total_revenue)*100,2),'%') AS '% of total sales'
FROM sales_per_category spc
CROSS JOIN total_gen;

-- cu filtrare pe o anumita luna (! filtrarea pe o anumita luna se face in interiorul fiecarui CTE)

WITH sales_per_category AS (
    SELECT ps.pizza_category, SUM(ps.total_price) AS total_revenue_categ
    FROM pizza_sales ps
    WHERE MONTH(STR_TO_DATE(ps.order_date, '%d/%m/%Y')) = 1
    GROUP BY ps.pizza_category
),
total_gen AS (
    SELECT SUM(ps.total_price) AS total_revenue
    FROM pizza_sales ps
    WHERE MONTH(STR_TO_DATE(ps.order_date, '%d/%m/%Y')) = 1
)
SELECT 
    spc.pizza_category,
    CONCAT(ROUND((total_revenue_categ / total_revenue) * 100, 2), '%') AS `% of total sales`
FROM sales_per_category spc
CROSS JOIN total_gen;

-- cu filtrare la nivel de quarter

WITH sales_per_category AS (
    SELECT ps.pizza_category, SUM(ps.total_price) AS total_revenue_categ
    FROM pizza_sales ps
    WHERE QUARTER(STR_TO_DATE(ps.order_date, '%d/%m/%Y')) = 1
    GROUP BY ps.pizza_category
),
total_gen AS (
    SELECT SUM(ps.total_price) AS total_revenue
    FROM pizza_sales ps
    WHERE QUARTER(STR_TO_DATE(ps.order_date, '%d/%m/%Y')) = 1
)
SELECT 
    spc.pizza_category,
    CONCAT(ROUND((total_revenue_categ / total_revenue) * 100, 2), '%') AS `% of total sales`
FROM sales_per_category spc
CROSS JOIN total_gen;


-- percentage of sales by pizza size

WITH sales_per_pizzaSize AS(
		SELECT ps.pizza_size, SUM(ps.total_price) AS total_revenue_categ
		FROM pizza_sales ps
		GROUP BY ps.pizza_size),
		
		total_gen AS(
		SELECT SUM(ps.total_price) AS total_revenue
		FROM pizza_sales ps)

SELECT spc.pizza_size, 
		 Concat(ROUND((total_revenue_categ / total_revenue)*100,2),'%') AS '% of total sales'
FROM sales_per_pizzaSize spc
CROSS JOIN total_gen
ORDER BY total_revenue_categ DESC;

-- top 5 best-selling pizzas by revenue, total quantity & total orders

SELECT ps.pizza_name,
		 Round(SUM(ps.total_price),2) AS Revenue,
		 SUM(ps.quantity) AS Total_Quantity,
		 COUNT(DISTINCT ps.order_id) AS Total_orders
FROM pizza_sales ps
GROUP BY ps.pizza_name
ORDER BY Revenue DESC,Total_Quantity DESC,Total_orders DESC 
LIMIT 5;


-- top 5 worst-selling pizzas by revenue, total quantity & total orders

SELECT ps.pizza_name,
		 Round(SUM(ps.total_price),2) AS Revenue,
		 SUM(ps.quantity) AS Total_Quantity,
		 COUNT(DISTINCT ps.order_id) AS Total_orders
FROM pizza_sales ps
GROUP BY ps.pizza_name
ORDER BY Revenue ASC,Total_Quantity ASC,Total_orders ASC
LIMIT 5;


-- v prof.

(SELECT 
    'Top 5' AS type,
    ps.pizza_name,
    SUM(ps.total_price) AS Revenue,
    SUM(ps.quantity) AS Total_Quantity,
    COUNT(DISTINCT ps.order_id) AS Total_orders
FROM pizza_sales ps
GROUP BY ps.pizza_name
ORDER BY Revenue DESC
LIMIT 5)

UNION ALL

(SELECT 
    'Bottom 5' AS type,
    ps.pizza_name,
   SUM(ps.total_price) AS Revenue,
    SUM(ps.quantity) AS Total_Quantity,
    COUNT(DISTINCT ps.order_id) AS Total_orders
FROM pizza_sales ps
GROUP BY ps.pizza_name
ORDER BY Revenue ASC
LIMIT 5);









