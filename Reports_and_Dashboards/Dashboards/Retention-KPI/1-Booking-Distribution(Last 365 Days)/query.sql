#standardsql
select
  d181_business_platform_code as channel,
  count(distinct order_id) as number_of_users
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
  group by user_id
  having count(distinct order_id) = 1)
and d181_business_platform_code is not null
and date(m01_order_datetime_gmt0) between date_sub(current_date(), interval 365 DAY) and current_date()
and d08_order_status_name = 'Active'
group by 1
order by 1
