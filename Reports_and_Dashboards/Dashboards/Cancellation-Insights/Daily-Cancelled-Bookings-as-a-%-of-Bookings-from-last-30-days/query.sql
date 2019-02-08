#standardsql
with cancelled as
(
select
date(m171_order_cancelled_datetime_gmt0) as cancelled_date,
count(distinct order_id) as cancelled_bookings
from
analyst.all_orders
where 1=1
-- and [[ date(m171_order_cancelled_datetime_gmt0) >= {{ date_range_start}} ]]
-- and [[ date(m171_order_cancelled_datetime_gmt0) <= {{ date_range_end}} ]]
and d08_order_status_name = 'Cancelled'
group by 1
order by 1
)
,
dates as
(
select
date,
date_add(date, interval -30 day) as days_ago_30
from
`bi_export.date`
where 1=1
and [[ date >= {{date_range_start}} ]]
and [[ date <= {{date_range_end}} ]]
order by 1 desc
)
,
daily_gbv as
(
select
date(m01_order_datetime_gmt0) as order_dt,
count(distinct order_id) as bookings
from
analyst.all_orders
group by 1
)
,
gbv_30_days as
(
select
date,
days_ago_30,
order_dt,
bookings
from
dates
join
daily_gbv
on order_dt between days_ago_30 and date
order by date, order_dt
)
,
final as
(
select
date,
sum(bookings) as bookings_past_30
from
gbv_30_days
group by 1
order by 1
)
select
date,
cancelled_bookings/bookings_past_30 as percent_cancelled
from
final
left join
cancelled
on 1=1
and date = cancelled_date
order by 1
