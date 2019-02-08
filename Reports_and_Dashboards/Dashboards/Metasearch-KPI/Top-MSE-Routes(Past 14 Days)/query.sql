#standardSQL
SELECT
CONCAT(IFNULL(d58_user_base_country_name,'null'),' -> ',IFNULL(d12_hotel_country_name,'null')) AS Routes,
ROUND(SUM(m07_selling_price_total_usd),0) as GBV,
COUNT(DISTINCT order_id) as Orders
FROM analyst.all_orders
WHERE 1=1
AND {{ @Include_Relevant_Meta }}
[[ and date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
[[ and date(m01_order_datetime_gmt0) <=  {{ date_range_end }}  ]]
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
