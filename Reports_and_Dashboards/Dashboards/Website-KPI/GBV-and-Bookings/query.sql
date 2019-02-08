select
  date(m01_order_datetime_gmt0) as dt,
  sum(m07_selling_price_total_usd) as GBV,
  count(distinct order_id) as Bookings
from
  analyst.all_orders
where
  1 = 1
  and d181_business_platform_code = 'website'
  and [[ date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
  and [[ date(m01_order_datetime_gmt0) <= {{ date_range_end }} ]]
group by 1
order by 1
