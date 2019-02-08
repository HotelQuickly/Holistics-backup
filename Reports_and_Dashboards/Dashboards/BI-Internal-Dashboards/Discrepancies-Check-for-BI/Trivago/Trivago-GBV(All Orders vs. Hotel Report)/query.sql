#standardSQL
WITH trivago_log_bookings_bookings AS
(
SELECT
Date(time) as date_1,
COUNT(DISTINCT CASE WHEN booking_status = 'Success' THEN session_id END) as log_bookings
FROM metasearch.log_booking
WHERE 1=1
AND consumer_code = 'trivago'
GROUP BY 1
),
trivago_all_orders_GBV_bookings AS
(
SELECT
DATE(m01_order_datetime_gmt0) as date_2,
COUNT(order_id) as all_orders_bookings,
SUM(m07_selling_price_total_usd) as all_orders_GBV
FROM
analyst.all_orders
WHERE lower(d180_order_referral_source_code) = 'trivago'
GROUP BY 1
),
trivago_sftp_data AS
(
SELECT
hotel_report.date as date_3,
SUM(bookings) as hotel_report_bookings,
ROUND(SUM(gross_rev*fx_rate.currency_rate),0) as hotel_report_GBV
FROM `metasearch_trivago_report_raw.hotel_report_*` as hotel_report
LEFT JOIN hqdatawarehouse.bi_export.fx_rate ON 1=1
AND fx_rate.date = hotel_report.date
AND prim_currency_code = 'EUR'
AND scnd_currency_code = 'USD'
GROUP BY 1
)
SELECT
date_2,
log_bookings,
all_orders_bookings,
hotel_report_bookings,
all_orders_GBV,
hotel_report_GBV
FROM trivago_all_orders_GBV_bookings
FULL OUTER JOIN trivago_log_bookings_bookings ON 1=1
AND trivago_log_bookings_bookings.date_1 = trivago_all_orders_GBV_bookings.date_2
FULL OUTER JOIN trivago_sftp_data ON 1=1
AND trivago_sftp_data.date_3 = trivago_all_orders_GBV_bookings.date_2
WHERE 1=1
[[ and date_2 >= {{ date_range_start }} ]]
[[ and date_2 <=  {{ date_range_end }}  ]]
ORDER BY 1 ASC
