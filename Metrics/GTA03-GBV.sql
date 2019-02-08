-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

select
  round(sum(m07_selling_price_total_usd),0)
from analyst.all_orders
where 1=1
and d22_inventory_source_code = 'gta03'
and {{time_where}}
