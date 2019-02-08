#standardsql
with
booking_rank_tbl as
  (
    select
      user_id,
      order_id,
      date(m01_order_datetime_gmt0) as booking_date,
      date_trunc(date(m01_order_datetime_gmt0), month) as booking_month,
      rank() over (partition by user_id order by order_id) as booking_rank,
      d181_business_platform_code channel
    from `analyst.all_orders`
    where date(d77_user_first_booking_datetime_gmt0) >= '2017-01-01'
    and d08_order_status_name = 'Active'
  ),
new_users_tbl as
  (
    select
      date_trunc(booking_date, month) as booking_month,
      count(user_id) as number_of_new_users
    from booking_rank_tbl
    where 1=1
    and booking_rank = 1
    and channel = 'metasearch'
    group by 1
    order by 1
  ),
booking_tracker_tbl as
  (
    select a.*, b.order_id as b_order_id, b.booking_date as b_booking_date, b.booking_month as b_booking_month, b.booking_rank as b_booking_rank, b.channel as b_channel
    from booking_rank_tbl a
    join booking_rank_tbl b
    on 1=1
    and a.user_id = b.user_id
    and a.booking_month < b.booking_month
    and a.booking_rank = 1
    order by 1,5,10
  )
    select
      a.booking_month as first_month,
      number_of_new_users,
      b.b_booking_month as repeat_month,
      --count(distinct b.user_id) as retained_users,
      concat(cast(round(count(distinct b.user_id)/number_of_new_users*100, 2) as string),'%') as percentage_retained
    from new_users_tbl a
    left join booking_tracker_tbl b
    on a.booking_month = b.booking_month
    where 1=1
    and b.channel = 'metasearch'
    and b.b_channel = 'website'

    group by 1,2,3
    order by 1,3
