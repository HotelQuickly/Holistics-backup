#standardsql
select
date_trunc(date(m01_order_datetime_gmt0) , {{ day_week_month|noquote }}) as order_date,
'GBV Today' as value,
d182_payment_gateway,
sum(m07_selling_price_total_usd ) as GBV
from
`analyst.all_orders`
where 1=1
and [[ date(m01_order_datetime_gmt0 ) >= {{date_range_start}} ]]
and [[ date(m01_order_datetime_gmt0 ) <= {{date_range_end}} ]]
and d182_payment_gateway is not null
group by 1,2,3

union all

select
date_trunc(date(m01_order_datetime_gmt0), {{ day_week_month|noquote }}) as order_date ,
'On Hold' as value,
d182_payment_gateway,
case when d182_payment_gateway = 'PAYPAL' then 0.18*sum(m07_selling_price_total_usd)
     else sum(m07_selling_price_total_usd) end
from
`analyst.all_orders`
where 1=1
and [[ date(m01_order_datetime_gmt0 ) >= {{date_range_start}} ]]
and [[ date(m01_order_datetime_gmt0 ) <= {{date_range_end}} ]]
and d182_payment_gateway is not null
group by 1,2,3

union all

select
date_trunc(date(m01_order_datetime_gmt0), {{ day_week_month|noquote }}) as order_date,
'Transaction Cost' as value,
d182_payment_gateway,
case when d182_payment_gateway = 'PAYPAL' then sum(0.024*m07_selling_price_total_usd)
     when d182_payment_gateway = 'STRIPE' then 0.0356*sum(m07_selling_price_total_usd)
     when d182_payment_gateway = 'STRIPE_UNSECURED' then 0.0356*sum(m07_selling_price_total_usd)
     when d182_payment_gateway = 'PRISMPAY' then 0.0356*sum(m07_selling_price_total_usd)
     when d182_payment_gateway = 'BRAINTREE' then 0.029*sum(m07_selling_price_total_usd) + 0.3*count(distinct order_id) end
from
`analyst.all_orders`
where 1=1
and [[ date(m01_order_datetime_gmt0 ) >= {{date_range_start}} ]]
and [[ date(m01_order_datetime_gmt0 ) <= {{date_range_end}} ]]
and d182_payment_gateway is not null
group by 1,2,3
order by 1 desc,2,3
