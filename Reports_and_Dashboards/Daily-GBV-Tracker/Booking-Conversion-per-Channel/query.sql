#standardSQL
WITH sessions_data AS
(
SELECT
date(log_availability.time) as date,
COUNT(DISTINCT CASE WHEN consumer_code = 'kayak' THEN session_id END) as kayak_sessions,
COUNT(DISTINCT CASE WHEN consumer_code = 'skyscanner' THEN session_id END) as skyscanner_sessions,
COUNT(DISTINCT CASE WHEN consumer_code = 'hotelscombined' THEN session_id END) as hotelscombined_sessions
FROM metasearch.log_availability
GROUP BY 1
),
ta_trivago_clicks AS
(SELECT
date,
trivago_clicks,
ta_clicks
FROM `analyst.ta_trivago_daily_report_data`
)
,
orders AS
(
SELECT
date(m01_order_datetime_gmt0) AS date,
count (distinct CASE WHEN lower(d180_order_referral_source_code) = 'hotelscombined' THEN order_id END ) AS hc_orders,
count (distinct CASE WHEN lower(d180_order_referral_source_code) = 'trivago' THEN order_id END ) AS trivago_orders,
count (distinct CASE WHEN lower(d180_order_referral_source_code) = 'tripadvisor' THEN order_id END ) AS ta_orders
FROM
analyst.all_orders
GROUP BY 1
)
SELECT
sessions_data.date,
SAFE_DIVIDE(trivago_orders,trivago_clicks) * 100 AS trivago,
SAFE_DIVIDE(ta_orders, ta_clicks) *100 AS tripadvisor,
SAFE_DIVIDE(hc_orders, hotelscombined_sessions) * 100 AS hotelscombined_sessions
FROM sessions_data
LEFT JOIN ta_trivago_clicks ON 1=1
AND sessions_data.date = ta_trivago_clicks.date
LEFT JOIN orders ON 1=1
AND orders.date = sessions_data.date
WHERE
[[ sessions_data.date >= {{ date_range_start }} ]]

[[ and sessions_data.date <=  {{ date_range_end }}  ]]
ORDER BY 1 ASC
