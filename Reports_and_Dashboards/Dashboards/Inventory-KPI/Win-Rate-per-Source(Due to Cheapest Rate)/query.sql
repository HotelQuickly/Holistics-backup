#standardsql
select
measured_date,
win_rate_hq*100 as hq,
win_rate_agodaparser*100 as agodaparser,
win_rate_expedia*100 as expedia,
win_rate_dotw*100 as dotw,
win_rate_gta*100 as gta,
win_rate_hotelbeds*100 as hotelbeds,
win_rate_siteminder*100 as siteminder,
win_rate_zumata*100 as zumata,
win_rate_gta03*100 as gta03,
win_rate_gta02*100 as gta02
from
`analyst.win_rate_across_source_*`
WHERE 1=1
-- _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_ADD(CURRENT_DATE, INTERVAL -90 DAY))
[[ and measured_date >= {{ date_range_start }} ]]
 [[ and measured_date <=  {{ date_range_end }}  ]]
order by measured_date
