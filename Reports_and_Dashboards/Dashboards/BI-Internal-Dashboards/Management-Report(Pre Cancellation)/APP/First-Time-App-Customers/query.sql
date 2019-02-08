#standardsql
select
order_month,
sum(bookings) as bookings,
sum(rns) as rns,
round(sum(gbv),0) as gbv,
round(sum(commission),0) as commission ,
round(sum(rns)/sum(bookings),0) as avg_rns_per_booking,
round(sum(gbv)/sum(rns),0) as avg_price_per_night
from
management_report.first_time_app_customers
where 1=1
AND DATE_DIFF(DATE_TRUNC(current_date, month), DATE_TRUNC(order_month, month),  month) >= 1
group by 1
order by 1 desc
