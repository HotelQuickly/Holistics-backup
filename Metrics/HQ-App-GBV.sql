-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}


#standardSQL
select
round(sum(m07_selling_price_total_usd), 0)
from
analyst.all_orders
where 1=1
and {{time_where}}
and {{ @Channel_Name }} = 'hqapp'
