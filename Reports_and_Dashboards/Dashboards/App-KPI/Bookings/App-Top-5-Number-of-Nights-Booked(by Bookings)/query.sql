#standardsql
select
  m03_count_of_nights_booked nights_booked,
  count(distinct order_id) as count
from analyst.all_orders
where d181_business_platform_code = 'app'
and  [[ DATE(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
and  [[ DATE(m01_order_datetime_gmt0) <=  {{ date_range_end }}  ]]
group by 1
order by 2 desc
limit 5
