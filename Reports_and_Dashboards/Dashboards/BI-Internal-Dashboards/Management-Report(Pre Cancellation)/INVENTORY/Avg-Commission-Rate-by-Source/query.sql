#standardsql
select
order_month,
d181_business_platform_code as business_platform,
round(direct_commission_rate*100,2) as direct_commission_rate,
round(gta_commission_rate*100,2) as gta_commission_rate,
round(hotelbeds_commission_rate*100,2) as hotelbeds_commission_rate,
round(expedia_commission_rate*100,2) as expedia_commission_rate,
round(dotw_commission_rate*100,2) as dotw_commission_rate
from
management_report.discounts_and_commission_by_source_and_channel
where d181_business_platform_code is not null
AND DATE_DIFF(DATE_TRUNC(current_date, month), DATE_TRUNC(order_month, month),  month) >= 1
group by 1,2,3,4,5,6,7
order by 1 desc, 2
