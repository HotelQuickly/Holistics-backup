#standardSQL
SELECT
Date,
SUM(CASE WHEN Channel = 'trivago' THEN GBV END) as Trivago,
SUM(CASE WHEN Channel = 'tripadvisor' THEN GBV END) as TripAdvisor,
SUM(CASE WHEN Channel = 'hotelscombined' THEN GBV END) as HotelsCombined,
SUM(CASE WHEN Channel NOT IN ('trivago','tripadvisor','hotelscombined') THEN GBV END) as Others
FROM
(
SELECT
date(m01_order_datetime_gmt0) as Date,
lower(d180_order_referral_source_code) as Channel,
ROUND(SUM(m07_selling_price_total_usd),0) as GBV
FROM analyst.all_orders
WHERE 1=1
AND {{ @Include_Relevant_Meta }}
[[ and date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
[[ and date(m01_order_datetime_gmt0) <=  {{ date_range_end }}  ]]
GROUP BY 1,2
ORDER BY 1 ASC
)
GROUP BY 1
ORDER BY 1 ASC
