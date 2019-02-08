#standardsql
select
date_trunc(m138_offer_checkin_date , {{ day_week_month|noquote }}) as checkin_date,
d22_inventory_source_code,
sum( m208_source_price_usd) as source_price
from
`analyst.all_orders`
where 1=1
-- and lower(d22_inventory_source_code) in ('hotelbeds', 'gta', 'dotw', 'expedia')
and d08_order_status_name = 'Active'
and [[ m138_offer_checkin_date >= {{date_range_start}} ]]
and [[ m138_offer_checkin_date <= {{date_range_end}} ]]
group by 1,2
order by 1 desc, 2
