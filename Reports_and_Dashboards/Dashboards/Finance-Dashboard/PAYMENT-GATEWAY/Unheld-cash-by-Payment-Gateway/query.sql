#standardsql
with paypal_on_hold as
(
select
date_trunc(dt2, {{ day_week_month|noquote }}) as dt2,
sum(paypal_unhold) as paypal_unhold
from
(
select
date(m01_order_datetime_gmt0) as dt1,
date_add(date(m01_order_datetime_gmt0), interval 120 day) as dt2,
sum(m07_selling_price_total_usd )*0.18 - sum(m07_selling_price_total_usd )*0.024 as paypal_unhold
from
analyst.all_orders
where 1=1
and d182_payment_gateway in ('PAYPAL')
and d08_order_status_name = 'Active'
group by 1,2
having dt2 <= current_date
order by 1 desc
)
where 1=1
and [[ dt2 >= {{date_range_start}} ]]
and [[ dt2 <= {{date_range_end}} ]]
group by 1
)

,

paypal as
(
select
date_trunc(date(m01_order_datetime_gmt0), {{ day_week_month|noquote }}) as dt1,
sum(m07_selling_price_total_usd )*0.82 - sum(m07_selling_price_total_usd )*0.024 as paypal_daily
from
analyst.all_orders
where 1=1
and d182_payment_gateway in ('PAYPAL')
and [[ date(m01_order_datetime_gmt0 ) >= {{date_range_start}} ]]
and [[ date(m01_order_datetime_gmt0 ) <= {{date_range_end}} ]]
group by 1
having dt1 <= current_date
order by 1 desc
)

,

prismpay as
(
select
date_trunc(dt2, {{ day_week_month|noquote }}) as dt2,
sum(prismpay_unhold) as prismpay_unhold
from
(
select
date(m01_order_datetime_gmt0) as dt1,
date_add(date(m01_order_datetime_gmt0), interval 14 day) as dt2,
sum(m07_selling_price_total_usd ) - sum(m07_selling_price_total_usd)*0.0356 as prismpay_unhold
from
analyst.all_orders
where 1=1
and d182_payment_gateway in ('PRISMPAY')
group by 1,2
having dt2 <= current_date
order by 1 desc
)
where 1=1
and [[ dt2 >= {{date_range_start}} ]]
and [[ dt2 <= {{date_range_end}} ]]
group by 1
)

,

stripe as
(
select
date_trunc(dt2, {{ day_week_month|noquote }}) as dt2,
sum(stripe_unhold) as stripe_unhold
from
(
select
date(m01_order_datetime_gmt0) as dt1,
date_add(date(m01_order_datetime_gmt0), interval 5 day) as dt2,
sum(m07_selling_price_total_usd ) - sum(m07_selling_price_total_usd)*0.0356 as stripe_unhold
from
analyst.all_orders
where 1=1
and d182_payment_gateway in ('STRIPE', 'STRIPE_UNSECURED')
group by 1,2
having dt2 <= current_date
order by 1 desc
)
where 1=1
and [[ dt2 >= {{date_range_start}} ]]
and [[ dt2 <= {{date_range_end}} ]]
group by 1
)

,

braintree as
(
select
date_trunc(dt2, {{ day_week_month|noquote }}) as dt2,
sum(gbv) as braintree_unhold
from
(
with gbv_by_dow as
(
select
date(m01_order_datetime_gmt0 ) as dt1,
format_date('%A', date(m01_order_datetime_gmt0 )) as dow,
case when d183_customer_charged_currency_id in (1, 3, 4, 5, 6) then 'major'
     else 'minor' end as currency_type,
sum(m07_selling_price_total_usd ) - sum(m07_selling_price_total_usd)*0.029 - 0.3*count(distinct order_id) as gbv
from
analyst.all_orders
where
d182_payment_gateway = 'BRAINTREE'
group by 1,2,3
order by 1 desc
)
select
dt1,
case when currency_type = 'major' then ( CASE when dow = 'Friday' then date_add(dt1, interval 3 day)
                                              when dow = 'Saturday' then date_add(dt1, interval 3 day)
                                              when dow = 'Sunday' then date_add(dt1, interval 2 day)
                                              else date_add(dt1, interval 1 day) end)
     else (case when dow = 'Thursday' then date_add(dt1, interval 4 day)
                when dow = 'Friday' then date_add(dt1, interval 4 day)
                when dow = 'Saturday' then date_add(dt1, interval 4 day)
                when dow = 'Sunday' then date_add(dt1, interval 3 day)
                else date_add(dt1, interval 2 day) end) end as dt2 ,
sum(gbv) as gbv
from
gbv_by_dow
group by 1,2
having dt2 <= current_date
order by 1 desc
)
where 1=1
and [[ dt2 >= {{date_range_start}} ]]
and [[ dt2 <= {{date_range_end}} ]]
group by 1
)

select
paypal_on_hold.dt2 as date,
paypal_unhold,
paypal_daily,
prismpay_unhold,
stripe_unhold,
braintree_unhold
from
paypal_on_hold
left join paypal
on 1=1
and paypal_on_hold.dt2 = paypal.dt1
left join prismpay
on 1=1
and paypal_on_hold.dt2 = prismpay.dt2
left join stripe
on 1=1
and paypal_on_hold.dt2 = stripe.dt2
left join braintree
on 1=1
and paypal_on_hold.dt2 = braintree.dt2
order by 1 desc
