#standardsql
select
  d22_inventory_source_code as inventory_source,
  sum(m07_selling_price_total_usd) as gbv
from analyst.all_orders
where d181_business_platform_code IN ('metasearch','website','app')
and  [[ DATE(m01_order_datetime_gmt0) >= ({{ date_range_start }}) ]]
and  [[ DATE(m01_order_datetime_gmt0) <=  ({{ date_range_end }})  ]]
group by 1
order by 2 desc
