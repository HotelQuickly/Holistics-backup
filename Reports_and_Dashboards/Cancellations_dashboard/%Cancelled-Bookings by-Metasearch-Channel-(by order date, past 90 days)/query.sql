#standardsql
select
channel,
(bookings/source_total*100) as percent_of_total
from
(
select
--order_date,
channel,
d08_order_status_name,
bookings ,
sum(bookings) over (partition by channel) as source_total
from
(
select
-- date(m01_order_datetime_gmt0) as order_date,
lower(d180_order_referral_source_code) AS channel,
d08_order_status_name,
count(distinct order_id) as bookings
from
analyst.all_orders
where 1=1
and date_diff(current_date, date(m01_order_datetime_gmt0), day) <= 90
and d181_business_platform_code = 'metasearch'
and d180_order_referral_source_code not in ('GOGOBOT', 'OPTIMISE-MEDIA-AFFILIATE')
group by 1,2
order by 1,2
)
)
where
d08_order_status_name = 'Cancelled'
order by 1,2
