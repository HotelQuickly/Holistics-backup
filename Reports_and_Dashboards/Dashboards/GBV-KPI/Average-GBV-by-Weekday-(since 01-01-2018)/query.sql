#standardSQL
SELECT
Weekday,
AVG(number),
ROUND(AVG(GBV),0) as Avg_GBV
FROM
(SELECT
date(m01_order_datetime_gmt0),
FORMAT_DATE("%A" , DATE(m01_order_datetime_gmt0)) as Weekday,
CAST(FORMAT_DATE("%u" , DATE(m01_order_datetime_gmt0)) as INT64) as number,
SUM(m07_selling_price_total_usd) as GBV
FROM `analyst.all_orders`
WHERE date(m01_order_datetime_gmt0) >= '2018-01-01'
GROUP BY 1,2,3
ORDER BY 2
)
GROUP BY 1
ORDER BY 2
