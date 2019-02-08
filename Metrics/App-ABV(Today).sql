-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

select round(sum( m07_selling_price_total_usd ) / count(distinct order_id),0)
from analyst.all_orders
where d181_business_platform_code = 'app'
and {{time_where}}
and time(m01_order_datetime_gmt0) <= current_time
