#standardsql
select
  date(m01_order_datetime_gmt0) as date,
  sum(case when  d04_device_type_name  = "ANDROID" then 1 else 0 end) android,
  sum(case when  d04_device_type_name  = "IPHONE" then 1 else 0 end) ios
from analyst.all_orders
where d181_business_platform_code = 'app'
and  [[ DATE(m01_order_datetime_gmt0) >= ({{ date_range_start }}) ]]
and  [[ DATE(m01_order_datetime_gmt0) <=  ({{ date_range_end }})  ]]
group by 1
order by 1 desc
