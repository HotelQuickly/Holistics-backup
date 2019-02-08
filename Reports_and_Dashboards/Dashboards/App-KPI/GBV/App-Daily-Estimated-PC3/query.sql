#standardsql
select
  date(m01_order_datetime_gmt0) as date,
  round(sum(m12_amount_of_commission_earned_usd) - sum(vouchers_used_usd_amount_m74) - sum(0.03*m07_selling_price_total_usd), 2) as pc3
from analyst.all_orders
where d181_business_platform_code = 'app'
and  [[ DATE(m01_order_datetime_gmt0) >= ({{ date_range_start }}) ]]
and  [[ DATE(m01_order_datetime_gmt0) <=  ({{ date_range_end }})  ]]
group by 1
order by 1 asc
