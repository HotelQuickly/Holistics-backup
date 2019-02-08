#standardsql
with
booking_rank_tbl as
  (
    select
      distinct user_id as user_id,
      order_id,
      d181_business_platform_code,
      rank() over (partition by user_id order by order_id) as booking_rank
    from `analyst.all_orders`
    where 1=1
    and user_id in
        (select
            user_id
        from `analyst.all_orders`
        where 1=1
        and d181_business_platform_code is not null
        and date(m01_order_datetime_gmt0) between date_sub(current_date(), interval 365 DAY) and current_date()
        and d08_order_status_name = 'Active'
        group by user_id having count(distinct order_id) = 2)
    and d181_business_platform_code is not null
    and date(m01_order_datetime_gmt0) between date_sub(current_date(), interval 365 DAY) and current_date()
    and d08_order_status_name = 'Active'
    order by 1,4
  ),
channels_per_user as
  (
    select
      distinct a.user_id,
      a.d181_business_platform_code as platform1,
      a.booking_rank as book1,
      b.d181_business_platform_code as platform2,
      b.booking_rank as book2
    from booking_rank_tbl a, booking_rank_tbl b
    where a.user_id = b.user_id
    and a.booking_rank = 1
    and b.booking_rank = 2
    order by 1
  )
select
  case
    when platform1 = 'app' and platform2 = 'app' then 'app -> app'
    when platform1 = 'app' and platform2 = 'metasearch' then 'app -> meta'
    when platform1 = 'app' and platform2 = 'website' then 'app -> web'
    when platform1 = 'metasearch' and platform2 = 'app' then 'meta -> app'
    when platform1 = 'metasearch' and platform2 = 'metasearch' then 'meta -> meta'
    when platform1 = 'metasearch' and platform2 = 'website' then 'meta -> web'
    when platform1 = 'website' and platform2 = 'app' then 'web -> app'
    when platform1 = 'website' and platform2 = 'metasearch' then 'web -> meta'
    when platform1 = 'website' and platform2 = 'website' then 'web -> web'
  END AS channel,
  count(user_id) as number_of_users
from channels_per_user
group by 1
order by 1
