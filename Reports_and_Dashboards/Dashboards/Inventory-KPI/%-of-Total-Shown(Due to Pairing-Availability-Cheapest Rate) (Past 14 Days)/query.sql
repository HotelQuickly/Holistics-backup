#standardsql
select
'hq' as source_code,
avg(show_rate_hq*100 )
from
`analyst.show_rate_across_sources_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_ADD(CURRENT_DATE, INTERVAL -7 DAY))

union all

select
'agodaparser' as source_code,
avg(show_rate_agodaparser*100)
from
`analyst.show_rate_across_sources_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_ADD(CURRENT_DATE, INTERVAL -7 DAY))

union all

select
'expedia' as source_code,
avg(show_rate_expedia*100)
from
`analyst.show_rate_across_sources_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_ADD(CURRENT_DATE, INTERVAL -7 DAY))

union all

select
'dotw' as source_code,
avg(show_rate_dotw*100)
from
`analyst.show_rate_across_sources_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_ADD(CURRENT_DATE, INTERVAL -7 DAY))

union all

select
'gta' as source_code,
avg(show_rate_gta*100)
from
`analyst.show_rate_across_sources_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_ADD(CURRENT_DATE, INTERVAL -7 DAY))

union all

select
'hotelbeds' as source_code,
avg(show_rate_hotelbeds*100)
from
`analyst.show_rate_across_sources_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_ADD(CURRENT_DATE, INTERVAL -7 DAY))

union all

select
'siteminder' as source_code,
avg(show_rate_siteminder*100)
from
`analyst.show_rate_across_sources_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_ADD(CURRENT_DATE, INTERVAL -7 DAY))

union all

select
'zumata' as source_code,
avg(show_rate_zumata*100)
from
`analyst.show_rate_across_sources_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_ADD(CURRENT_DATE, INTERVAL -7 DAY))

union all

select
'gta03' as source_code,
avg(show_rate_gta03*100)
from
`analyst.show_rate_across_sources_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_ADD(CURRENT_DATE, INTERVAL -7 DAY))

union all

select
'gta02' as source_code,
avg(show_rate_gta02*100)
from
`analyst.show_rate_across_sources_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_ADD(CURRENT_DATE, INTERVAL -7 DAY))
