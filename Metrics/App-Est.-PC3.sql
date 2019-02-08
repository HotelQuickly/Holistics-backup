-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

select
  round(sum( m12_amount_of_commission_earned_usd) - sum(vouchers_used_usd_amount_m74) - sum(0.03 * m07_selling_price_total_usd),0)
from analyst.all_orders
where d181_business_platform_code = 'app'
and {{time_where}}
