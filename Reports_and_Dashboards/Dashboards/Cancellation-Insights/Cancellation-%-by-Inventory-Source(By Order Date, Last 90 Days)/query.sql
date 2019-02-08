#standardsql
select
d22_inventory_source_code,
(bookings/source_total*100) as percent_of_total
from
(
select
--order_date,
d22_inventory_source_code,
d08_order_status_name,
bookings ,
sum(bookings) over (partition by d22_inventory_source_code) as source_total
from
(
select
-- date(m01_order_datetime_gmt0) as order_date,
d22_inventory_source_code,
d08_order_status_name,
count(distinct order_id) as bookings
from
analyst.all_orders
where 1=1
and date_diff(current_date, date(m01_order_datetime_gmt0), day) <= 90
--and lower(d22_inventory_source_code) in ('hotelbeds','gta','dotw')
group by 1,2
order by 1,2
)
)
where
d08_order_status_name = 'Cancelled'
order by 1,2
