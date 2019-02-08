#standardSQL
SELECT
Date,
SUM(CASE WHEN Channel = 'trivago' THEN Bookings END) as Trivago,
SUM(CASE WHEN Channel = 'tripadvisor' THEN Bookings END) as TripAdvisor,
SUM(CASE WHEN Channel = 'hotelscombined' THEN Bookings END) as Hotelscombined,
SUM(CASE WHEN Channel NOT IN ('trivago','tripadvisor','hotelscombined') THEN Bookings END) as Others
FROM
(SELECT
date(m01_order_datetime_gmt0) as Date,
lower(c) as Channel,
COUNT(DISTINCT order_id) as Bookings
FROM analyst.all_orders
WHERE 1=1
AND {{ @Include_Relevant_Meta }}
[[ and date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
[[ and date(m01_order_datetime_gmt0) <=  {{ date_range_end }}  ]]
GROUP BY 1,2
ORDER BY 1 ASC
)
GROUP BY 1
