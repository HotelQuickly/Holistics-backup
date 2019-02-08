#standardSQL
SELECT
date(m01_order_datetime_gmt0) as date,
sum(m07_selling_price_total_usd) AS gbv,
count(distinct order_id) AS orders,
sum(m03_count_of_nights_booked) as RNS
FROM
analyst.all_orders
where d22_inventory_source_code='expedia' AND
d181_business_platform_code='metasearch'
--hotel_id in (select distinct hotel_id from ad_hoc_projects.ean_experiment where hotel_id in ('64659'))
and [[{{date(m01_order_datetime_gmt0) >= '2018-10-08'}}]]
group by 1
order by 1 asc
