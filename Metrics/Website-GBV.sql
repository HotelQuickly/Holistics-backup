-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

select
sum(m07_selling_price_total_usd)
from
analyst.all_orders
where
d181_business_platform_code = 'website'
and {{time_where}}
