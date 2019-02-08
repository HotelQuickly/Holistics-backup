#standardsql
select
  d58_user_base_country_name as user_country,
  sum(m07_selling_price_total_usd) as gbv,
  count(distinct order_id) as bookings
from analyst.all_orders
where d181_business_platform_code = 'website'
and  [[ DATE(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
and  [[ DATE(m01_order_datetime_gmt0) <=  {{ date_range_end }}  ]]
group by 1
order by 2 desc
limit 10
