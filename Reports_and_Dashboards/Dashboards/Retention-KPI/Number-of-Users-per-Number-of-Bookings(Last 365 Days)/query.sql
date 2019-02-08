#standardsql
with
bookings_per_user as
  (
    select
      user_id,
      count(distinct order_id) number_of_bookings
    from `analyst.all_orders`
    where 1=1
    and d181_business_platform_code is not null
    and date(m01_order_datetime_gmt0) between date_sub(current_date(), interval 365 DAY) and current_date()
    and d08_order_status_name = 'Active'
    group by 1
    order by 1
  )
select
  case
    when number_of_bookings = 1 then '1'
    when number_of_bookings = 2 then '2'
    when number_of_bookings = 3 then '3'
    else '>3'
  end as number_of_bookings,
  count(user_id) as number_of_users
from bookings_per_user
group by 1
order by 1
