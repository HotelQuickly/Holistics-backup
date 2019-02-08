#standardsql
with cancelled as
(
select
cancelled_month,
user_country,
round(sum(gbv),0) as cancelled_gbv
from
management_report.top_10_user_country_gbv_all
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
user_country,
round(sum(gbv),0) as gbv
from
management_report.top_10_user_country_gbv_all
WHERE DATE_DIFF(DATE_TRUNC(current_date, month), DATE_TRUNC(order_month, month),  month) >= 1
group by 1,2
order by 1 desc
)
select
order_month,
pre.user_country,
round(sum(gbv) - sum(cancelled_gbv),0) as gbv
from
pre
left join cancelled
on 1=1
and order_month = cancelled.cancelled_month
and pre.user_country = cancelled.user_country
group by 1,2
order by 1 desc
