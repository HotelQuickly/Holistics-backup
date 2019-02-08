-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

#standardsql
SELECT
SUM(trivago_bookings+ta_bookings)/SUM(trivago_clicks+ta_clicks)
FROM
(
WITH booking_data AS
(
SELECT
date(m01_order_datetime_gmt0) as Date1,
IFNULL(COUNT(DISTINCT CASE WHEN lower(d180_order_referral_source_code) = 'tripadvisor' THEN order_id END),0) as ta_bookings,
IFNULL(COUNT(DISTINCT CASE WHEN lower(d180_order_referral_source_code) = 'trivago' THEN order_id END),0) as trivago_bookings
FROM `analyst.all_orders`
GROUP BY 1
)
SELECT
booking_data.date1 as Date,
ta_clicks,
trivago_clicks,
ta_bookings,
trivago_bookings
FROM
booking_data
  LEFT JOIN analyst.ta_trivago_daily_report_data ON 1=1
  AND ta_trivago_daily_report_data.date =  booking_data.date1
)
WHERE {{time_where}}
