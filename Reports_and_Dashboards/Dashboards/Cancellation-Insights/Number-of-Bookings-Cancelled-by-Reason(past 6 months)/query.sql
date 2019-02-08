#standardsql
select
d166_order_cancelled_reason_code,
count(distinct order_id) as bookings
from
analyst.all_orders
where
d08_order_status_name = 'Cancelled'
and date_diff(current_date, date(m01_order_datetime_gmt0), day) <= 180
group by 1
order by 2 desc
