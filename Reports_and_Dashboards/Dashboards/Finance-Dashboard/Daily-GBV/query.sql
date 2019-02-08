#standardsql
with order_gbv_today as
(
select
date_trunc(date(m01_order_datetime_gmt0 ), {{ day_week_month|noquote }})  as order_date,
sum(m07_selling_price_total_usd ) as gbv
from `analyst.all_orders`
where 1=1
and [[ date(m01_order_datetime_gmt0 ) >= {{date_range_start}} ]]
and [[ date(m01_order_datetime_gmt0 ) <= {{date_range_end}} ]]
group by 1
order by 1 desc
)
,
cancelled_gbv_today as
(
select
date_trunc(date(m171_order_cancelled_datetime_gmt0 ), {{ day_week_month|noquote }}) as cancelled_date,
sum(m07_selling_price_total_usd ) as cancelled_gbv
from `analyst.all_orders`
where 1=1
and d08_order_status_name = 'Cancelled'
and [[ date(m171_order_cancelled_datetime_gmt0 ) >= {{date_range_start}} ]]
and [[ date(m171_order_cancelled_datetime_gmt0 ) <= {{date_range_end}} ]]
group by 1
order by 1 desc
)
select
order_date,
gbv,
cancelled_gbv,
gbv -  cancelled_gbv as total
from
order_gbv_today
left join
cancelled_gbv_today
on 1=1
and order_date = cancelled_date
order by 1 desc
