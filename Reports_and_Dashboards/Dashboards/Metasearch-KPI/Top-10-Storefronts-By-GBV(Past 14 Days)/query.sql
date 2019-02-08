#standardSQL
SELECT
IFNULL(d58_user_base_country_name,'null') as Search_Country,
ROUND(SUM(m07_selling_price_total_usd),0) as GBV
FROM analyst.all_orders
WHERE 1=1
AND {{ @Include_Relevant_Meta }}
[[ AND date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
[[ AND date(m01_order_datetime_gmt0) <=  {{ date_range_end }}  ]]
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
