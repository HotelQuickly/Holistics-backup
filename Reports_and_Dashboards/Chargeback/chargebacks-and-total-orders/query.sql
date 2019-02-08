#standardsql
with orders as (
select
  case when d182_payment_gateway = 'STRIPE_UNSECURED' then 'stripe unsecured' else lower(d182_payment_gateway) end as d182_payment_gateway,
  d185_credit_card_name,
  count(distinct order_id) as total_orders
from `analyst.all_orders`
where 1 = 1
and [[ date(m01_order_datetime_gmt0) >= {{ date_range_start }}]]
and [[ date(m01_order_datetime_gmt0) <= {{ date_range_end }}]]
group by 1,2
)
,
chargebacks_tbl as
(
select
payment_gateway_name,
credit_card_name ,
count(distinct order_id) as charge_backs
from
`bi_export.chargeback`
where 1=1
and [[ date(chargeback_dt) >= {{ date_range_start }}]]
and [[ date(chargeback_dt) <= {{ date_range_end }}]]
group by 1,2
)
select
payment_gateway_name,
credit_card_name ,
charge_backs chargebacks,
ifnull(total_orders,0) total_orders,
ifnull(safe_divide(charge_backs,total_orders), 0) as chargeback_as_percent_of_total
from
chargebacks_tbl
left join
orders
on 1=1
and d182_payment_gateway = lower(payment_gateway_name)
and d185_credit_card_name =  credit_card_name
where 1=1
and [[ lower(payment_gateway_name) =  {{ payment_gateway }}]]
group by 1,2,3,4,5
order by 1,2
