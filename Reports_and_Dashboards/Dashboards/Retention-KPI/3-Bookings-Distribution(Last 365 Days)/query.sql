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
        group by user_id having count(distinct order_id) = 3)
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
      b.booking_rank as book2,
      c.d181_business_platform_code as platform3,
      c.booking_rank as book3
    from booking_rank_tbl a, booking_rank_tbl b, booking_rank_tbl c
    where 1=1
    and a.user_id = b.user_id
    and a.user_id = c.user_id
    and a.booking_rank = 1
    and b.booking_rank = 2
    and c.booking_rank = 3
    order by 1
  )
select
  case
    when platform1 = 'app' and platform2 = 'app' and platform3 = 'app' then 'app -> app -> app'
    when platform1 = 'app' and platform2 = 'app' and platform3 = 'metasearch' then 'app -> app -> meta'
    when platform1 = 'app' and platform2 = 'app' and platform3 = 'website' then 'app -> app -> web'
    when platform1 = 'app' and platform2 = 'metasearch' and platform3 = 'app' then 'app -> meta -> app'
    when platform1 = 'app' and platform2 = 'metasearch' and platform3 = 'metasearch' then 'app -> meta -> meta'
    when platform1 = 'app' and platform2 = 'metasearch' and platform3 = 'website' then 'app -> meta -> web'
    when platform1 = 'app' and platform2 = 'website' and platform3 = 'app' then 'app -> web -> app'
    when platform1 = 'app' and platform2 = 'website' and platform3 = 'metasearch' then 'app -> web-> meta'
    when platform1 = 'app' and platform2 = 'website' and platform3 = 'website' then 'app -> web -> web'
    when platform1 = 'metasearch' and platform2 = 'app' and platform3 = 'app' then 'meta -> app -> app'
    when platform1 = 'metasearch' and platform2 = 'app' and platform3 = 'metasearch' then 'meta -> app -> meta'
    when platform1 = 'metasearch' and platform2 = 'app' and platform3 = 'website' then 'meta -> app -> web'
    when platform1 = 'metasearch' and platform2 = 'metasearch' and platform3 = 'app' then 'meta -> meta -> app'
    when platform1 = 'metasearch' and platform2 = 'metasearch' and platform3 = 'metasearch' then 'meta -> meta -> meta'
    when platform1 = 'metasearch' and platform2 = 'metasearch' and platform3 = 'website' then 'meta -> meta -> web'
    when platform1 = 'metasearch' and platform2 = 'website' and platform3 = 'app' then 'meta -> web -> app'
    when platform1 = 'metasearch' and platform2 = 'website' and platform3 = 'metasearch' then 'meta -> web -> meta'
    when platform1 = 'metasearch' and platform2 = 'website' and platform3 = 'website' then 'meta -> web -> web'
    when platform1 = 'website' and platform2 = 'app' and platform3 = 'app' then 'web -> app -> app'
    when platform1 = 'website' and platform2 = 'app' and platform3 = 'metasearch' then 'web -> app -> meta'
    when platform1 = 'website' and platform2 = 'app' and platform3 = 'website' then 'web -> app -> web'
    when platform1 = 'website' and platform2 = 'metasearch' and platform3 = 'app' then 'web -> meta -> app'
    when platform1 = 'website' and platform2 = 'metasearch' and platform3 = 'metasearch' then 'web -> meta -> meta'
    when platform1 = 'website' and platform2 = 'metasearch' and platform3 = 'website' then 'web -> meta -> web'
    when platform1 = 'website' and platform2 = 'website' and platform3 = 'app' then 'web -> web -> app'
    when platform1 = 'website' and platform2 = 'website' and platform3 = 'metasearch' then 'web -> web -> meta'
    when platform1 = 'website' and platform2 = 'website' and platform3 = 'website' then 'web -> web -> web'
  end as channel,
  count(user_id) as number_of_users
from channels_per_user
group by 1
order by 2 desc
