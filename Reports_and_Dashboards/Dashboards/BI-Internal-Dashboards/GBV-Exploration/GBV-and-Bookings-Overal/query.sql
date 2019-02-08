#standardSQL
SELECT
date(m01_order_datetime_gmt0) AS Date,
COUNT(DISTINCT order_id) as Orders,
SUM(m07_selling_price_total_usd) as GBV
FROM
analyst.all_orders
where 1=1
and [[ date(m01_order_datetime_gmt0) >= date_add({{ single_date }}, interval -30 DAY ) ]]
and date(m01_order_datetime_gmt0) < current_date()
GROUP BY 1
ORDER BY 1 DESC
