#standardsql
with app_installed_count as
(
  select
    'number of installs' as type,
    count(distinct user_id) as number_of_users
  from `bi_export.user`
  where 1=1
  and d181_business_platform_code = 'app'
  and d121_first_user_indicator = 'YES'
  and d130_test_user_indicator = 'NO'
  -- and date(d111_first_device_install_datetime_gmt0) >= '2017-01-01'
  [[ and date(d111_first_device_install_datetime_gmt0) >= {{ date_range_start }} ]]
  [[ and date(d111_first_device_install_datetime_gmt0) <= {{ date_range_end }} ]]
),
allorders_ranked as
(
select
  user_id,
  date(m01_order_datetime_gmt0) booking_date,
  rank() over(partition by user_id order by m01_order_datetime_gmt0) as r
from `analyst.all_orders`
where d181_business_platform_code = 'app'
order by user_id, r
),
allorders_app as
(
select
  a.user_id,
  a.booking_date as first_booking_date,
  a.r as first_r,
  b.booking_date as next_booking_date,
  b.r as next_r
from allorders_ranked a, allorders_ranked b
where 1=1
and a.user_id = b.user_id
and a.r = 1
and b.r >= 1
-- and a.booking_date >= '2017-01-01'
[[ and a.booking_date >= {{ date_range_start }} ]]
[[ and a.booking_date <= {{ date_range_end }} ]]
order by 2,1,3,5
),
allorders_funnel as
(
select
  next_r as type,
  count(distinct user_id) number_of_users
from allorders_app
group by 1
order by 1
limit 10
)
select * from app_installed_count

union all

select
  concat(cast(type as string), " booking(s)"),
  number_of_users
from allorders_funnel
order by 2 desc
