#standardsql
select date,
sum(case when source = 'agodaparser01' then availability end) as agodaparser,
sum(case when source = 'dotw01' then availability end) as dotw,
sum(case when source = 'expedia01' then availability end) as expedia,
sum(case when source = 'gta01' then availability end) as gta,
sum(case when source = 'hotelbeds01' then availability end) as hotelbeds,
sum(case when source = 'hq01' then availability end) as hq,
sum(case when source = 'siteminder01' then availability end) as siteminder,
sum(case when source = 'zumata01' then availability end) as zumata
FROM
(
select
measured_date as date,
lower(source) as source,
round(sum(isac)/sum(isc)*100,2) as availability
from
`analyst.daily_isc_isac_per_source_*`
where 1=1
AND  _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_ADD(CURRENT_DATE, INTERVAL -90 DAY))
 [[ and measured_date >= {{ date_range_start }} ]]
 [[ and measured_date <=  {{ date_range_end }}  ]]
group by 1,2
)
group by 1
order by 1
