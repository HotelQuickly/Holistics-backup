-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

SELECT
round(sum(m07_selling_price_total_usd), 0)
FROM analyst.all_orders
where 1=1
and d181_business_platform_code = 'metasearch'
and {{time_where}}
