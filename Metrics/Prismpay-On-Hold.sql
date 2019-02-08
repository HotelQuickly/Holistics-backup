-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}
select
sum(m07_selling_price_total_usd) - sum(m07_selling_price_total_usd)*0.0356
from
analyst.all_orders
where
date_diff(current_date, date(m01_order_datetime_gmt0), day) <= 14
and lower(d182_payment_gateway) = 'prismpay'
and d08_order_status_name = 'Active'
