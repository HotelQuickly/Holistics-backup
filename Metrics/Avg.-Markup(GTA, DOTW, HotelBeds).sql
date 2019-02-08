-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

select
avg(markup)
from
(
select
m01_order_datetime_gmt0,
(m07_selling_price_total_usd - m208_source_price_usd )/m208_source_price_usd as markup
from
`analyst.all_orders`
where 1=1
and lower(d22_inventory_source_code ) = 'gta03'
-- m01_order_datetime_gmt0  = {{time_where}}
group by 1,2
order by 1
)
where
{{time_where}}
