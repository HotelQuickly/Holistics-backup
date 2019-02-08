#standardsql
select order_date,
sum(case when d22_inventory_source_code = 'agodaparser' then abv end) as agodaparser,
sum(case when d22_inventory_source_code = 'dotw' then abv end) as dotw,
sum(case when d22_inventory_source_code = 'expedia' then abv end) as expedia,
sum(case when d22_inventory_source_code = 'gta03' then abv end) as gta03,
sum(case when d22_inventory_source_code = 'hotelbeds' then abv end) as hotelbeds,
sum(case when d22_inventory_source_code = 'hq' then abv end) as hq,
sum(case when d22_inventory_source_code = 'siteminder' then abv end) as siteminder,
sum(case when d22_inventory_source_code = 'zumata' then abv end) as zumata,
sum(case when d22_inventory_source_code = 'gta02' then abv end) as gta02,
sum(case when d22_inventory_source_code = 'gta' then abv end) as gta,
avg(case when d22_inventory_source_code NOT IN ('zumata','siteminder','hq','hotelbeds','gta03','gta', 'gta02', 'expedia','dotw','agodaparser') then abv end) as others
FROM(
SELECT
  DATE(m01_order_datetime_gmt0) as order_date,
  d22_inventory_source_code,
  round(SUM(m07_selling_price_total_usd)/COUNT(DISTINCT order_id),2) AS abv
FROM
  `analyst.all_orders`
WHERE
  1=1
  [[ and DATE(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
  [[ and DATE(m01_order_datetime_gmt0) <=  {{ date_range_end }}  ]]
GROUP BY 1,2
)
GROUP BY 1
ORDER by 1
