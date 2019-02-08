-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

select
sum(CASE WHEN lower(d08_order_status_name) = 'cancelled' THEN m07_selling_price_total_usd END)
/
sum(m07_selling_price_total_usd)
from
analyst.all_orders
where {{time_where}}
