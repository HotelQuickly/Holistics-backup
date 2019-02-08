#standardSQL
select
date_trunc(DATE(m01_order_datetime_gmt0),{{ day_week_month|noquote }} ),
sum(case when d22_inventory_source_code = 'agodaparser' then m07_selling_price_total_usd end) as agodaparser,
sum(case when d22_inventory_source_code = 'dotw' then m07_selling_price_total_usd end) as dotw,
sum(case when d22_inventory_source_code = 'expedia' then m07_selling_price_total_usd end) as expedia,
sum(case when d22_inventory_source_code = 'gta' then m07_selling_price_total_usd end) as gta,
sum(case when d22_inventory_source_code = 'hotelbeds' then m07_selling_price_total_usd end) as hotelbeds,
sum(case when d22_inventory_source_code = 'hq' then m07_selling_price_total_usd end) as hq,
sum(case when d22_inventory_source_code = 'siteminder' then m07_selling_price_total_usd end) as siteminder,
sum(case when d22_inventory_source_code = 'zumata' then m07_selling_price_total_usd end) as zumata,
sum(case when d22_inventory_source_code NOT IN ('zumata','siteminder','hq','hotelbeds','gta','gta','expedia','dotw','agodaparser') then m07_selling_price_total_usd end) as others
from
analyst.all_orders
where
[[ date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
and  [[ date(m01_order_datetime_gmt0) <= {{ date_range_end }} ]]
group by 1
order by 1
