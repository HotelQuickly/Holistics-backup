#standardsql
with cancelled as
(
select
cancelled_month,
inventory_source,
round(sum(gbv),0) as cancelled_gbv
from
management_report.gbv_by_inventory_source
where d08_order_status_name = 'Cancelled'
AND DATE_DIFF(DATE_TRUNC(current_date, month), DATE_TRUNC(cancelled_month, month),  month) >= 1
group by 1,2
order by 1 desc
)
,
pre as
(
select
order_month,
inventory_source,
round(sum(gbv),0) as gbv
from
management_report.gbv_by_inventory_source
WHERE DATE_DIFF(DATE_TRUNC(current_date, month), DATE_TRUNC(order_month, month),  month) >= 1
group by 1,2
order by 1 desc
)
,
post_cancellation_gbv as
(
select
order_month,
pre.inventory_source,
round(sum(gbv) - sum(cancelled_gbv),0) as gbv
from
pre
left join cancelled
on 1=1
and order_month = cancelled.cancelled_month
and pre.inventory_source = cancelled.inventory_source
WHERE DATE_DIFF(DATE_TRUNC(current_date, month), DATE_TRUNC(order_month, month),  month) >= 1
group by 1,2
)
,
inventory_gbv as
(
select
order_month,
inventory_source,
gbv,
(gbv/month_total)*100 as percent_total
from
(
select
order_month,
inventory_source,
gbv,
sum(gbv) over (partition by order_month) AS month_total
from
(
select
order_month,
inventory_source,
sum(gbv) as gbv
from post_cancellation_gbv
WHERE DATE_DIFF(DATE_TRUNC(current_date, month), DATE_TRUNC(order_month, month),  month) >= 1
group by 1, 2
order by 1 desc
)
group by 1,2,3
)
group by 1,2,3,4
)

select
order_month,
'GBV' as value,
inventory_source,
round(gbv,0)
from inventory_gbv
group by 1,2,3,4

UNION ALL

select
order_month,
'% of Total' as value,
inventory_source,
round(percent_total,2)
from inventory_gbv
group by 1,2,3,4
order by 1 desc, 2 desc
