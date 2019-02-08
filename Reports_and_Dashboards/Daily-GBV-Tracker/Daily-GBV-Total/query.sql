#standardSQL
select
date_trunc(DATE(m01_order_datetime_gmt0), DAY),
{{ @Channel_Name }},
sum(m07_selling_price_total_usd) as gbv
from
analyst.all_orders
where
date(m01_order_datetime_gmt0) >= {{ date_range_start }}
and date(m01_order_datetime_gmt0) <= {{ date_range_end }}
group by 1,2
