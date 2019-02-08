#standardsql
with all_commission as
(
select
date_trunc(date(m01_order_datetime_gmt0), {{ day_week_month|noquote }} ) as order_date,
d22_inventory_source_code ,
sum(m208_source_price_usd  ) as source_price
from
`analyst.all_orders`
where 1=1
and [[ date(m01_order_datetime_gmt0 ) >= {{date_range_start}} ]]
and [[ date(m01_order_datetime_gmt0 ) <= {{date_range_end}} ]]
group by 1,2
)
,
cancelled_commission as
(
select
date_trunc(date(m171_order_cancelled_datetime_gmt0),{{ day_week_month|noquote }}) as cancelled_date,
d22_inventory_source_code ,
sum(m208_source_price_usd  ) as source_price_cancelled
from
`analyst.all_orders`
where
d08_order_status_name = 'Cancelled'
and [[ date(m01_order_datetime_gmt0 ) >= {{date_range_start}} ]]
and [[ date(m01_order_datetime_gmt0 ) <= {{date_range_end}} ]]
group by 1,2
)
select
order_date,
all_commission.d22_inventory_source_code ,
source_price,
source_price_cancelled,
(source_price
-
source_price_cancelled) as diff
from
all_commission
left join
cancelled_commission
on 1=1
and order_date = cancelled_date
and all_commission.d22_inventory_source_code =  cancelled_commission.d22_inventory_source_code
order by 1 , 2
