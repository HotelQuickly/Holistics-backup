#standardsql
select
date_trunc(date(m01_order_datetime_gmt0) , {{ day_week_month|noquote }}) as order_date,
d22_inventory_source_code,
sum( m208_source_price_usd) as source_price
from
`analyst.all_orders`
where 1=1
and [[ date(m01_order_datetime_gmt0 ) >= {{date_range_start}} ]]
and [[ date(m01_order_datetime_gmt0 ) <= {{date_range_end}} ]]
group by 1,2
order by 1 desc, 2
