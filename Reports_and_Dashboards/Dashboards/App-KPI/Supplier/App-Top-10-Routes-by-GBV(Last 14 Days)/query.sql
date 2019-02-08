#standardsql
SELECT
  CONCAT(IFNULL(d58_user_base_country_name,'null'),'-> ',IFNULL(d12_hotel_country_name,'null')) AS routes,
  sum(m07_selling_price_total_usd) AS gbv,
  count(distinct order_id) as bookings
FROM
analyst.all_orders
where 1=1
and d181_business_platform_code = 'app'
and  [[ DATE(m01_order_datetime_gmt0) >= ({{ date_range_start }}) ]]
and  [[ DATE(m01_order_datetime_gmt0) <=  ({{ date_range_end }})  ]]
group by 1
order by 2 desc
limit 10
