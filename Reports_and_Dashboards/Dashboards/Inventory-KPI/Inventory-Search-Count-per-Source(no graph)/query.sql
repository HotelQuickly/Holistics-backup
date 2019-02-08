#standardsql
select measured_date,
sum(case when source = 'agodaparser01' then isc end) as agodaparser,
sum(case when source = 'dotw01' then isc end) as dotw,
sum(case when source = 'expedia01' then isc end) as expedia,
sum(case when source = 'gta01' then isc end) as gta,
sum(case when source = 'hotelbeds01' then isc end) as hotelbeds,
sum(case when source = 'hq01' then isc end) as hq,
sum(case when source = 'siteminder01' then isc end) as siteminder,
sum(case when source = 'zumata01' then isc end) as zumata
FROM
(
SELECT
  measured_date,
  lower(source) as source,
  isc
FROM
  `analyst.daily_isc_isac_per_source_*`
WHERE
 _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_ADD(CURRENT_DATE, INTERVAL -90 DAY))
 [[ and measured_date >= {{ date_range_start }} ]]
 [[ and measured_date <=  {{ date_range_end }}  ]]
GROUP BY
  1,
  2,
  3
)
group by 1
order by 1;
