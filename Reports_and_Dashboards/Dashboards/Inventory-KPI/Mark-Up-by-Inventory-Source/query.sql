#standardSQL
SELECT
date,
SUM(CASE WHEN inventory_source = 'hotelbeds' THEN markup_amount END) as hotelbeds,
SUM(CASE WHEN inventory_source = 'gta03' THEN markup_amount END) as gta03,
SUM(CASE WHEN inventory_source = 'dotw' THEN markup_amount END) as dotw
--SUM(CASE WHEN inventory_source = 'hq' THEN markup_amount END) as hq
FROM
(
SELECT
Date(m01_order_datetime_gmt0) as date,
lower(d22_inventory_source_code) as inventory_source,
SAFE_DIVIDE((SUM(m07_selling_price_total_usd) - SUM(m208_source_price_usd)),SUM(m208_source_price_usd)) as markup_amount
FROM `analyst.all_orders`
WHERE Date(m01_order_datetime_gmt0) > '2017-01-01'
GROUP BY 1,2
ORDER BY 1 ASC
)
WHERE 1=1
[[ and date >= {{ date_range_start }} ]]
[[ and date <=  {{ date_range_end }}  ]]
GROUP BY 1
ORDER BY 1 DESC
