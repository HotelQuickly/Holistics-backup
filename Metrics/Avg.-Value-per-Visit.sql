-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

with clicks as
(
select
date_trunc(date(time), month) as dt1,
count(distinct session_id) as clicks_1
from
`metasearch_raw.log_availability_hotelquickly_website_*`
group by 1
)
,
gbv as
(
select
date_trunc(date(m01_order_datetime_gmt0), month) as dt,
count(distinct order_id ) as bookings,
sum(m07_selling_price_total_usd ) as gbv_1
from
`analyst.all_orders`
where
d181_business_platform_code = 'website'
and date_diff(current_date, date(m01_order_datetime_gmt0),month) = 1
group by 1
)
select
sum(gbv_1)/sum(clicks_1)
from
gbv
left join clicks
on dt = dt1
