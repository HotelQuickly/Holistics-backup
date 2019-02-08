-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

select
round(sum( case when date(m171_order_cancelled_datetime_gmt0) =  current_date then m07_selling_price_total_usd end), 0)
from
analyst.all_orders
where
date_diff(current_date, date(m01_order_datetime_gmt0), day) <= 30
