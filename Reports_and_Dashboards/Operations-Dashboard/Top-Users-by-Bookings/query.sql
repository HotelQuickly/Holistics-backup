#standardSQL
SELECT
user_id,
d58_user_base_country_name,
d13_user_full_name,
count(distinct order_id) AS orders,
sum(m07_selling_price_total_usd) AS gbv
FROM
analyst.all_orders
where 1=1
and [[ date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
and [[ date(m01_order_datetime_gmt0) <= {{ date_range_end }} ]]
and [[ d08_order_status_name IN({{ order_status }}) ]]
group by 1,2,3
having count(distinct order_id) > 2
order by 4 desc
