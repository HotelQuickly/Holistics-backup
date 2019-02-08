#standardSQL
select
DATE(m01_order_datetime_gmt0) report_date,
{{ @Channel_Name }} channel,
sum(m07_selling_price_total_usd) as gbv
from
analyst.all_orders
where 1=1
and [[ date(m01_order_datetime_gmt0) >= date_add({{ single_date }}, interval -30 DAY ) ]]
and date(m01_order_datetime_gmt0) < current_date()
group by 1,2
order by 1
