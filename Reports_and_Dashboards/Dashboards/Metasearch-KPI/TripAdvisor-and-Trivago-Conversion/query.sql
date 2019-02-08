#standardsql
SELECT
Date,
SUM(CASE WHEN Channel='trivago' THEN Conversion END) as Trivago,
SUM(CASE WHEN Channel='tripadvisor' THEN Conversion END) as TripAdvisor
FROM
(
WITH booking_data AS
(
SELECT
date(m01_order_datetime_gmt0) as Date1,
lower(d180_order_referral_source_code) as Channel1,
IFNULL(COUNT(DISTINCT order_id),0) as Bookings
FROM `analyst.all_orders`
WHERE lower(d180_order_referral_source_code) IN ('tripadvisor','trivago')
GROUP BY 1,2
)
SELECT
booking_data.date1 as Date,
Channel1 as Channel,
CASE
  WHEN Channel1 = 'tripadvisor' THEN (sum(bookings)/sum(ta_clicks))
  WHEN Channel1 = 'trivago' THEN (sum(bookings)/sum(trivago_clicks))
  END as Conversion
 FROM
booking_data
  LEFT JOIN analyst.ta_trivago_daily_report_data ON 1=1
  AND ta_trivago_daily_report_data.date =  booking_data.date1
GROUP BY 1,2
ORDER BY 1 DESC
)
WHERE 1=1
[[ and Date >= {{ date_range_start }} ]]
[[ and Date <=  {{ date_range_end }}  ]]
GROUP BY 1
ORDER BY 1 ASC
