select
  date(m01_order_datetime_gmt0) as dt,
  d22_inventory_source_code as inventory_source,
  sum(m07_selling_price_total_usd) as GBV
from
  analyst.all_orders
where
  1 = 1
  and d181_business_platform_code = 'website'
  and [[ date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
  and [[ date(m01_order_datetime_gmt0) <= {{ date_range_end }} ]]
group by 1,2
order by 1,2
