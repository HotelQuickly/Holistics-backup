#standardsql
select
date_trunc(date(m01_order_datetime_gmt0), {{ day_week_month|noquote }}) as order_date,
d22_inventory_source_code,
sum(m12_amount_of_commission_earned_usd) as commission
from
analyst.all_orders
where 1=1
and [[ date(m01_order_datetime_gmt0 ) >= {{date_range_start}} ]]
and [[ date(m01_order_datetime_gmt0 ) <= {{date_range_end}} ]]
and lower(d22_inventory_source_code) in ('zumata', 'hq', 'siteminder', 'agodaparser')
group by 1,2
order by 1 desc
