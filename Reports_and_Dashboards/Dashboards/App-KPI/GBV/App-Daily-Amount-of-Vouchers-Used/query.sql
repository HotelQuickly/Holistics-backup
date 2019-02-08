#standardsql
select
  date(m01_order_datetime_gmt0) as date,
  sum(m12_amount_of_commission_earned_usd) as commission_earned,
  sum(vouchers_used_usd_amount_m74) as voucher_cost
from analyst.all_orders
where d181_business_platform_code = 'app'
and  [[ DATE(m01_order_datetime_gmt0) >= ({{ date_range_start }}) ]]
and  [[ DATE(m01_order_datetime_gmt0) <=  ({{ date_range_end }})  ]]
group by 1
order by 1 asc
