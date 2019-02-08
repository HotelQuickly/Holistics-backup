#standardSQL
SELECT
*
FROM
(
SELECT
hq_hotel_id,
d15_hotel_name as hotel_name,
hotel_city,
gbv_rank,
AVG(availability) as availability
FROM
(WITH top_hotels AS
(
SELECT
hotel_id,
d10_hotel_city_name as hotel_city,
SUM(m07_selling_price_total_usd) as GBV,
rank() OVER (ORDER BY SUM(m07_selling_price_total_usd) DESC) as gbv_rank
FROM hqdatawarehouse.analyst.all_orders
WHERE 1=1
and  [[ d10_hotel_city_name in ({{ hotel_city }}) ]]
AND date(m01_order_datetime_gmt0) >= DATE_ADD(current_date, INTERVAL -365 day)
GROUP BY 1,2
ORDER BY 2 DESC
LIMIT 100
)
SELECT
hq_hotel_id,
hotel_city,
measured_date,
days_in_advance_group,
gbv_rank,
SUM(tsac)/SUM(tsc) as availability
FROM `inventory_raw.total_search_*`
RIGHT JOIN top_hotels ON 1=1
AND hotel_id = hq_hotel_id
WHERE 1=1
AND _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_ADD(CURRENT_DATE, INTERVAL -3 DAY))
and date_diff(current_date, measured_date, day) <= 3
and  [[ CAST(days_in_advance_group as STRING) in ({{ days_in_advances_group }}) ]]
GROUP BY 1,2,3,4,5
ORDER BY 1 DESC
)
LEFT JOIN bi_export.hotel ON 1=1
AND hq_hotel_id = hotel_id
WHERE availability > 0.35
GROUP BY 1,2,3,4
ORDER BY gbv_rank ASC
)
