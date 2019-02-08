#standardsql
with c_gbv as
(
select
date(m171_order_cancelled_datetime_gmt0) as cancellation_date,
d12_hotel_country_name,
sum(m07_selling_price_total_usd) as cancelled_gbv
from
analyst.all_orders
where
d12_hotel_country_name is not null
and m171_order_cancelled_datetime_gmt0 is not null
and [[ date(m171_order_cancelled_datetime_gmt0) >= {{ date_range_start }} ]]
and [[ date(m171_order_cancelled_datetime_gmt0) <= {{ date_range_end }} ]]
group by 1,2
)
,
gbv_rank as
(
select
cancellation_date,
d12_hotel_country_name,
cancelled_gbv,
rank() over (partition by cancellation_date order by cancelled_gbv DESC) as rnk
from
c_gbv
where
d12_hotel_country_name is not null
group by 1,2,3
order by 1 desc, 4
)
select
cancellation_date,
d12_hotel_country_name,
cancelled_gbv
from
gbv_rank
where
rnk <= 10
and cancelled_gbv > 1000
