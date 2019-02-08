#standardsql
select
measured_date,
show_rate_hq*100 as hq,
show_rate_agodaparser*100 as agodaparser,
show_rate_expedia*100 as expedia,
show_rate_dotw*100 as dotw,
show_rate_gta*100 as gta,
show_rate_hotelbeds*100 as hotelbeds,
show_rate_siteminder*100 as siteminder,
show_rate_zumata*100 as zumata,
show_rate_gta03*100 as gta03,
show_rate_gta02*100 as gta02
from
`analyst.show_rate_across_source_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_ADD(CURRENT_DATE, INTERVAL -90 DAY))
[[ and measured_date >= {{ date_range_start }} ]]
 [[ and measured_date <=  {{ date_range_end }}  ]]
order by measured_date
