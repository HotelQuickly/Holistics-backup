#standardSQL
SELECT
date(m01_order_datetime_gmt0) as Date,
ROUND(SUM(m07_selling_price_total_usd),0) as GBV
FROM analyst.all_orders
WHERE 1=1
AND {{ @Include_Relevant_Meta }}
[[ and date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
[[ and date(m01_order_datetime_gmt0) <=  {{ date_range_end }}  ]]
GROUP BY 1
ORDER BY 1 ASC
