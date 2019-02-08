#standardSQL
SELECT
CONCAT({{ @Channel_Name }} ,' x ',d22_inventory_source_code) AS channelxsource,
sum(m07_selling_price_total_usd) AS gbv,
count(distinct order_id) AS orders
FROM
analyst.all_orders
where
date(m01_order_datetime_gmt0) >= {{ date_range_start }}
and date(m01_order_datetime_gmt0) <= {{ date_range_end }}
group by 1
order by 2 desc
LIMIT 15
