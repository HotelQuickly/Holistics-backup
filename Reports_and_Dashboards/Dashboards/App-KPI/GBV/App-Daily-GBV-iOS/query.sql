#standardsql
select
  date(m01_order_datetime_gmt0) as date,
  sum(case when d04_device_type_name = 'IPHONE' then m07_selling_price_total_usd end ) as ios_gbv
from analyst.all_orders
where d181_business_platform_code = 'app'
and  [[ DATE(m01_order_datetime_gmt0) >= ({{ date_range_start }}) ]]
and  [[ DATE(m01_order_datetime_gmt0) <=  ({{ date_range_end }})  ]]
group by 1
order by 1 asc
