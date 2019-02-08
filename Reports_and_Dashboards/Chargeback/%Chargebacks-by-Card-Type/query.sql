#standardsql
select
credit_card_name	,
count(distinct order_id) as orders
from
bi_export.chargeback
where 1=1
and [[ date(chargeback_dt) >= {{ date_range_start }}]]
and [[ date(chargeback_dt) <= {{ date_range_end }}]]
and [[ lower(payment_gateway_name) =  {{ payment_gateway }}]]
group by 1
