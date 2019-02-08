#standardSQL
WITH othermse_log_bookings_bookings AS
(
SELECT
Date(time) as date_1,
COUNT(DISTINCT CASE WHEN booking_status = 'Success' THEN session_id END) as log_bookings
FROM metasearch.log_booking
WHERE 1=1
AND consumer_code IN ('hotelscombined','skyscanner','kayak')
GROUP BY 1
),
othermse_all_orders_GBV_bookings AS
(
SELECT
DATE(m01_order_datetime_gmt0) as date_2,
COUNT(order_id) as all_orders_bookings,
SUM(m07_selling_price_total_usd) as all_orders_GBV
FROM
analyst.all_orders
WHERE lower(d180_order_referral_source_code) IN ('hotelscombined','skyscanner','kayak')
GROUP BY 1
)
SELECT
date_2,
log_bookings,
all_orders_bookings
FROM othermse_all_orders_GBV_bookings
FULL OUTER JOIN othermse_log_bookings_bookings ON 1=1
AND othermse_log_bookings_bookings.date_1 = othermse_all_orders_GBV_bookings.date_2
WHERE 1=1
[[ and date_2 >= {{ date_range_start }} ]]
[[ and date_2 <=  {{ date_range_end }}  ]]
ORDER BY 1 DESC
