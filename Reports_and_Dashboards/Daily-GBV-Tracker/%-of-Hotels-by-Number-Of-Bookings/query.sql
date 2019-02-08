#standardSQL
SELECT
CASE
WHEN bookings = 1 THEN 'A) 1 Booking'
WHEN bookings = 2 THEN 'B) 2 Bookings'
WHEN bookings = 3 THEN 'C) 3 Bookings'
WHEN bookings = 4 THEN 'D) 4 Bookings'
WHEN bookings = 5 THEN 'E) 5 Bookings'
WHEN bookings > 5 and bookings <= 10 THEN 'F) 6 - 10 Bookings'
WHEN bookings > 10 and bookings <= 20 THEN 'G) 11 - 20 Bookings'
WHEN bookings > 20 and bookings <= 50 THEN 'H) 21 - 50 Bookings'
WHEN bookings > 50 and bookings <= 100 THEN 'I) 51 - 100 Bookings'
ELSE 'J) 101 and More Bookings' END as Booking_Groups,
COUNT(DISTINCT hotel_id) as Number_Of_Hotels
FROM
(
SELECT
hotel_id,
COUNT(distinct order_id) as bookings,
SUM(m07_selling_price_total_usd) as GBV
FROM `analyst.all_orders`
WHERE Date(m01_order_datetime_gmt0) >= DATE_ADD(current_date, INTERVAL -180 day)
GROUP BY 1
HAVING bookings > 0
ORDER BY 2 DESC
)
GROUP BY 1
ORDER BY 1 ASC
