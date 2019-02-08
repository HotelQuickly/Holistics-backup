#standardsql
select
  case
    when number_of_bookings = 1 then '1'
    when number_of_bookings = 2 then '2'
    when number_of_bookings = 3 then '3'
    else '>3' end as number_of_bookings,
  count(user_id) as number_of_users
from
  (select
    user_id,
    count(distinct order_id) number_of_bookings
  from `analyst.all_orders`
  where 1=1
  and d181_business_platform_code is not null
  and date_trunc(date(m01_order_datetime_gmt0), year) = '2017-01-01'
  group by 1
  order by 1) as a
group by 1
order by 1
