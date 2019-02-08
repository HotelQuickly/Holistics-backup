#standardsql
select
order_month,
'GBV' as value,
user_country,
round(sum(gbv),0) as gbv
from
management_report.top_10_app_countries_gbv_vouchers
WHERE DATE_DIFF(DATE_TRUNC(current_date, month), DATE_TRUNC(order_month, month),  month) >= 1
group by 1,2,3


UNION ALL

select
order_month,
'% Voucher Used' as value,
user_country,
round(sum(voucher_used)/sum(gbv)*100,2) as _percent_voucher_usage
from
management_report.top_10_app_countries_gbv_vouchers
WHERE DATE_DIFF(DATE_TRUNC(current_date, month), DATE_TRUNC(order_month, month),  month) >= 1
group by 1,2,3
order by 1 desc, 3, 4 desc
