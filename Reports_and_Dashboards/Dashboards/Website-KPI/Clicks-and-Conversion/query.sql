#standardsql
with cl as
(
select
date(time) as dt,
count(distinct session_id) as clicks
from
metasearch.log_availability
where
consumer_code = 'hotelquickly-website'
and [[ date(time) >= {{ date_range_start }} ]]
and [[ date(time) <= {{ date_range_end }} ]]
group by 1
order by 1
)
,
bk as
(
select
date(m01_order_datetime_gmt0) as dt1,
count(distinct order_id) as bookings
from
analyst.all_orders
where 1=1
and [[ date(m01_order_datetime_gmt0) >= {{date_range_start}} ]]
and [[ date(m01_order_datetime_gmt0) <= {{date_range_end}} ]]
and d181_business_platform_code = 'website'
group by 1
)
select
dt,
clicks,
bookings/clicks as conversion
from
cl
left join bk
on 1=1
and dt = dt1
group by 1,2,3
order by 1
