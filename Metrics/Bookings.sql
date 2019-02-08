-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

SELECT
COUNT(DISTINCT order_id)
FROM analyst.all_orders
WHERE 1=1
--AND d181_business_platform_code = 'metasearch'
AND {{time_where}}
and TIME(m01_order_datetime_gmt0) < CURRENT_TIME
