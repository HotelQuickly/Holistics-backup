#standardsql
select
  d10_hotel_city_name as city,
  sum(m07_selling_price_total_usd) as gbv,
  count(distinct order_id) as bookings
from analyst.all_orders
where d181_business_platform_code = 'app'
and  [[ DATE(m01_order_datetime_gmt0) >= ({{ date_range_start }}) ]]
and  [[ DATE(m01_order_datetime_gmt0) <=  ({{ date_range_end }})  ]]
group by 1
order by 2 desc
limit 10
