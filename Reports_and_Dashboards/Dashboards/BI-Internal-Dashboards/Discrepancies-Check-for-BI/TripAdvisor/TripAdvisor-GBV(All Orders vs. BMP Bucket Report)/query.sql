#standardSQL
WITH tripadvisor_log_bookings_bookings AS
(
SELECT
Date(time) as date_1,
COUNT(DISTINCT CASE WHEN booking_status = 'Success' THEN session_id END) as log_bookings
FROM metasearch.log_booking
WHERE 1=1
AND consumer_code = 'tripadvisor'
GROUP BY 1
),
tripadvisor_all_orders_GBV_bookings AS
(
SELECT
DATE(m01_order_datetime_gmt0) as date_2,
COUNT(order_id) as all_orders_bookings,
SUM(m07_selling_price_total_usd) as all_orders_GBV
FROM
analyst.all_orders
WHERE lower(d180_order_referral_source_code) = 'tripadvisor'
GROUP BY 1
),
tripadvisor_sftp_data AS
(
SELECT
ds as date_3,
sum(bookings) as bmp_bookings,
sum(gross_booking_value_usd) as bmp_GBV
FROM `metasearch_tripadvisor_report.bmp_bucket_from_past_year`
GROUP BY 1
)
SELECT
date_2 as Date,
log_bookings,
all_orders_bookings,
bmp_bookings,
all_orders_GBV,
bmp_GBV
FROM tripadvisor_all_orders_GBV_bookings
FULL OUTER JOIN tripadvisor_log_bookings_bookings ON 1=1
AND tripadvisor_log_bookings_bookings.date_1 = tripadvisor_all_orders_GBV_bookings.date_2
FULL OUTER JOIN tripadvisor_sftp_data ON 1=1
AND tripadvisor_sftp_data.date_3 = tripadvisor_all_orders_GBV_bookings.date_2
WHERE 1=1
[[ and date_2 >= {{ date_range_start }} ]]
[[ and date_2 <=  {{ date_range_end }}  ]]
ORDER BY 1 DESC
