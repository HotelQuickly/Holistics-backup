#standardSQL
SELECT
Date,
SUM(CASE WHEN Channel = 'kayak' THEN Conversion END) as kayak,
SUM(CASE WHEN Channel = 'skyscanner' THEN Conversion END) as skyscanner,
SUM(CASE WHEN Channel = 'hotelscombined' THEN Conversion END) as hotelscombined
FROM
(
WITH session_info AS
(
SELECT
date(log_availability.time) as date1,
log_availability.consumer_code as channel1,
COUNT(DISTINCT log_availability.session_id) as sessions
FROM metasearch.log_availability
WHERE 1=1
[[ and date(time) >= {{ date_range_start }} ]]
[[ and date(time) <=  {{ date_range_end }}  ]]
AND consumer_code IN ('kayak','skyscanner','hotelscombined')
GROUP BY 1,2
),
booking_info AS
(
SELECT
date(m01_order_datetime_gmt0) as date2,
lower(d180_order_referral_source_code) as channel2,
COUNT (DISTINCT order_id) as bookings
FROM `analyst.all_orders`
WHERE 1=1
[[ and date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
[[ and date(m01_order_datetime_gmt0) <=  {{ date_range_end }}  ]]
AND lower(d180_order_referral_source_code) IN ('kayak','skyscanner','hotelscombined')
GROUP BY 1,2
)
SELECT
session_info.date1 as Date,
channel1 as Channel,
ROUND((sum(bookings)/sum(sessions))*100,2) as Conversion
FROM session_info
LEFT JOIN booking_info ON 1=1
AND session_info.date1 = booking_info.date2
AND session_info.channel1 = booking_info.channel2
GROUP BY 1,2
)
GROUP BY 1
ORDER BY 1 ASC
