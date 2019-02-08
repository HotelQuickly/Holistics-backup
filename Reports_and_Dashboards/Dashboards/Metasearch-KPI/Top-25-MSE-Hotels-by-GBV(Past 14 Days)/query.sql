#standardSQL
SELECT
CONCAT(IFNULL(d11_hotel_country_code,'null') ,': ',d15_hotel_name) AS Hotel_Name,
SUM(m07_selling_price_total_usd) AS GBV,
COUNT(distinct order_id) AS Orders
FROM
analyst.all_orders
WHERE 1=1
AND {{ @Include_Relevant_Meta }}
[[ AND date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
[[ AND date(m01_order_datetime_gmt0) <=  {{ date_range_end }}  ]]
GROUP BY 1
ORDER BY 2 DESC
LIMIT 25
