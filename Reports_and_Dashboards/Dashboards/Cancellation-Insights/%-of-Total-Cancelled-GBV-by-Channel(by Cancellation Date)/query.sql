#standard_sql
select
cancelled_date,
channel,
(cancelled_gbv/day_total) as percent_of_total
from
(
select
cancelled_date,
channel,
cancelled_gbv,
sum(cancelled_gbv) over (partition by cancelled_date) as day_total
from
(
select
date(m171_order_cancelled_datetime_gmt0) as cancelled_date,
lower(d180_order_referral_source_code) as channel,
sum(m07_selling_price_total_usd) as cancelled_gbv
from
analyst.all_orders
where 1=1
and [[ date(m171_order_cancelled_datetime_gmt0) >= {{ date_range_start}} ]]
and [[ date(m171_order_cancelled_datetime_gmt0) <= {{ date_range_end}} ]]
and d181_business_platform_code = 'metasearch'
and d08_order_status_name = 'Cancelled'
group by 1,2
order by 1,2
)
)
order by 1
