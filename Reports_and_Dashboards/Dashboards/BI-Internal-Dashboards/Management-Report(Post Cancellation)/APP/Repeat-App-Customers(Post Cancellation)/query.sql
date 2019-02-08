#standardsql
with cancelled as
(
select
cancelled_month,
sum(bookings) as cancelled_bookings,
sum(rns) as cancelled_rns,
round(sum(gbv),0) as cancelled_gbv,
round(sum(commission),0) as cancelled_commission ,
round(sum(rns)/sum(bookings),0) as cancelled_avg_rns_per_booking,
round(sum(gbv)/sum(rns),0) as cancelled_avg_price_per_night
from
management_report.repeat_app_customers
where d08_order_status_name = 'Cancelled'
AND DATE_DIFF(DATE_TRUNC(current_date, month), DATE_TRUNC(cancelled_month, month),  month) >= 1
group by 1
order by 1 desc
)
,
pre as
(
select
order_month,
sum(bookings) as bookings,
sum(rns) as rns,
round(sum(gbv),0) as gbv,
round(sum(commission),0) as commission ,
round(sum(rns)/sum(bookings),0) as avg_rns_per_booking,
round(sum(gbv)/sum(rns),0) as avg_price_per_night
from
management_report.repeat_app_customers
WHERE DATE_DIFF(DATE_TRUNC(current_date, month), DATE_TRUNC(order_month, month),  month) >= 1
group by 1
order by 1 desc
)
select
order_month,
sum(bookings) - sum(cancelled_bookings) as bookings,
sum(rns) - sum(cancelled_rns) as rns,
round(sum(gbv) - sum(cancelled_gbv),0) as gbv,
round(sum(commission) - sum(cancelled_commission),0) as commission ,
round(((sum(rns) - sum(cancelled_rns))/(sum(bookings)- sum(cancelled_bookings))),0) as avg_rns_per_booking,
round(((sum(gbv)- sum(cancelled_gbv))/(sum(rns) - sum(cancelled_rns))),0) as avg_price_per_night
from
pre
left join cancelled
on 1=1
and order_month = cancelled.cancelled_month
group by 1
order by 1 desc
