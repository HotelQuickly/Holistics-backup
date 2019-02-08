#standardSQL
WITH
searches AS
(
SELECT
hour as hour_1,
ROUND(AVG(searches),0) as avg_searches
FROM
(
SELECT
Date(measured_datetime),
TIME_TRUNC(TIME(measured_datetime), HOUR) as hour,
COUNT(*) as searches
FROM `inventory_raw.search_*`
WHERE 1=1
AND  _TABLE_SUFFIX >= FORMAT_DATE("%Y%m%d", DATE_SUB(CURRENT_DATE(), INTERVAL 110 DAY))
GROUP BY 1,2
ORDER BY 3 desc
)
GROUP BY 1
ORDER BY 1
),
bookings AS
(SELECT
hour as hour_2,
ROUND(AVG(bookings),0) as avg_bookings
FROM
(
SELECT
Date(m01_order_datetime_gmt0),
TIME_TRUNC(TIME(m01_order_datetime_gmt0), HOUR) as hour,
COUNT(*) as bookings
FROM `analyst.all_orders`
WHERE 1=1
AND Date(m01_order_datetime_gmt0) >= DATE_ADD(current_date, INTERVAL -130 day)
GROUP BY 1,2
ORDER BY 3 desc
)
GROUP BY 1
ORDER BY 1
)
SELEcT
hour_1 as time_hour,
avg_bookings,
avg_searches
FROM searches
INNER JOIN bookings ON 1=1
AND hour_1 = hour_2
ORDER BY 1
