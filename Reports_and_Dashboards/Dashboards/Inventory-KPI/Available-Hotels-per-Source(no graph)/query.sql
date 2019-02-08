#standardsql
select measured_date,
sum(case when source = 'agodaparser01' then available_hotels_per_source end) as agodaparser,
sum(case when source = 'dotw01' then available_hotels_per_source end) as dotw,
sum(case when source = 'expedia01' then available_hotels_per_source end) as expedia,
sum(case when source = 'gta01' then available_hotels_per_source end) as gta,
sum(case when source = 'hotelbeds01' then available_hotels_per_source end) as hotelbeds,
sum(case when source = 'hq01' then available_hotels_per_source end) as hq,
sum(case when source = 'siteminder01' then available_hotels_per_source end) as siteminder,
sum(case when source = 'zumata01' then available_hotels_per_source end) as zumata
FROM
(
SELECT
  measured_date,
  lower(source) as source,
  available_hotels_per_source
FROM `analyst.daily_isc_isac_per_source_*`
WHERE 1=1
AND  _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_ADD(CURRENT_DATE, INTERVAL -90 DAY))
 [[ and measured_date >= {{ date_range_start }} ]]
 [[ and measured_date <=  {{ date_range_end }}  ]]
)
group by 1
