#standardsql
select
order_month,
round(direct_discount*100,2) as direct_discount,
round(gta_discount*100,2) as gta_discount,
round(hotelbeds_discount*100,2) as hotelbeds_discount,
round(expedia_discount*100,2) as expedia_discount,
round(dotw_discount*100,2) as dotw_discount
from
management_report.discounts_and_commission_by_source_and_channel
where lower(d181_business_platform_code) = 'app'
AND DATE_DIFF(DATE_TRUNC(current_date, month), DATE_TRUNC(order_month, month),  month) >= 1
group by 1,2,3,4,5,6
order by 1 desc
