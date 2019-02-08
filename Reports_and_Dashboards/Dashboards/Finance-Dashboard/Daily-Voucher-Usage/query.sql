#standardsql
select
date_trunc(date(m01_order_datetime_gmt0), {{ day_week_month|noquote }} ) as order_date,
sum(vouchers_used_usd_amount_m74 ) as voucher_used
from
`analyst.all_orders`
where 1=1
and [[ date(m01_order_datetime_gmt0 ) >= {{date_range_start}} ]]
and [[ date(m01_order_datetime_gmt0 ) <= {{date_range_end}} ]]
group by 1
order by 1 desc
