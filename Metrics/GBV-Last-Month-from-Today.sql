-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

#standardSQL
SELECT
round(SUM(m07_selling_price_total_usd), 0)

FROm analyst.all_orders
WHERE 1=1
AND Date(m01_order_datetime_gmt0) >=  DATE_ADD(DATE_ADD(current_date(),INTERVAL -EXTRACT(DAY FROM CURRENT_DATE())+1 Day), INTERVAL -1 Month)
AND  Date(m01_order_datetime_gmt0)<= DATE_ADD(CURRENT_DATE(), INTERVAL -EXTRACT(DAY FROM CURRENT_DATE()) DAY)
