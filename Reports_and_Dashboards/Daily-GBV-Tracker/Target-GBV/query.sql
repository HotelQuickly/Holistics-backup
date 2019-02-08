#standardsql
with dates as(
select
target_dates,
date_add(target_dates, interval -365 day) as target_last_year
from
(
select date as target_dates from `bi_export.date`
where date_diff(date, current_date, day) <= 30
and date_diff(current_date, date, day) <= 90
order by date desc
))
,
gbv_base_1 as (
select date( m01_order_datetime_gmt0) as order_date1,
sum( m07_selling_price_total_usd) as gbv1
from `analyst.all_orders`
where date(m01_order_datetime_gmt0) <> current_date
group by 1
)
,
gbv_base_2 as (
select date( m01_order_datetime_gmt0) as order_date2,
sum( m07_selling_price_total_usd) as gbv2
from `analyst.all_orders`
group by 1
)
select
target_dates,
target_last_year,
gbv1 as gbv_this_year,
gbv2 as gbv_last_year
--gbv2*1.2 as gbv_last_year_20_percent_higher,
--gbv2*1.5 as gbv_last_year_50_percent_higher,
--gbv2*2 as gbv_last_year_100_percent_higher
from
dates
left join gbv_base_1
on 1=1
and target_dates = order_date1
left join gbv_base_2
on 1=1
and target_last_year = order_date2
