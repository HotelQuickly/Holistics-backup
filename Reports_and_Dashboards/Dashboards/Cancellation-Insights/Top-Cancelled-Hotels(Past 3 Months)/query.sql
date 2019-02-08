#standardsql
SELECT
hotel_id,
d15_hotel_name,
COUNT(DISTINCT order_id) as Bookings,
COUNT(DISTINCT CASE WHEN d08_order_status_name = 'Cancelled' THEN order_id END) as Cancelled_Bookings,
SUM(m07_selling_price_total_usd) as GBV,
COUNT(DISTINCT CASE WHEN d08_order_status_name = 'Cancelled' THEN order_id END)/COUNT(distinct order_id) as Cancellation_Rate_By_Bookings,
SUM(CASE WHEN d08_order_status_name = 'Cancelled' THEN m07_selling_price_total_usd END)/SUM(m07_selling_price_total_usd ) as Cancellation_Rate_By_GBV
FROM `analyst.all_orders`
WHERE 1=1
AND DATE(m01_order_datetime_gmt0) >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
GROUP BY 1,2
HAVING Bookings > 5
ORDER BY Cancellation_Rate_By_Bookings DESC, Cancelled_Bookings  DESC
