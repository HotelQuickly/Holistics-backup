#standardsql
select
order_month,
hotel_country,
round(sum(gbv),0) as gbv
from
management_report.top_10_hotel_country_gbv_all
WHERE DATE_DIFF(DATE_TRUNC(current_date, month), DATE_TRUNC(order_month, month),  month) >= 1
group by 1,2
order by 1 desc, 3 desc
