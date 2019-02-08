-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

#standardSQL
select
round(sum(m07_selling_price_total_usd)
/
TIME_DIFF(CURRENT_TIME,TIME "00:00:00",SECOND), 2)
from
analyst.all_orders
where {{time_where}}
and TIME(m01_order_datetime_gmt0) < CURRENT_TIME
