-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}


select
(
round(sum(m07_selling_price_total_usd)
/
count(distinct date(m01_order_datetime_gmt0)), 0)
)
*31
from
analyst.all_orders
where {{time_where}}
