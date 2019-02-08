-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

SELECT
round(sum(m12_amount_of_commission_earned_usd), 0)
FROM analyst.all_orders
WHERE 1=1
AND d181_business_platform_code = 'metasearch'
AND {{time_where}}
