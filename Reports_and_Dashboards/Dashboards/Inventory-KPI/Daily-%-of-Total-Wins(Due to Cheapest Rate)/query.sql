#standardsql
select
measured_date,
win_rate_zumata as zumata,
win_rate_hq as hq ,
win_rate_expedia as expedia ,
win_rate_dotw as dotw ,
win_rate_gta as gta,
win_rate_hotelbeds as hotelbeds,
win_rate_siteminder as siteminder,
win_rate_gta03 as gta03,
win_rate_gta02 as gta02
from
`analyst.win_rate_across_sources_*`
where 1=1
and [[ measured_date >= {{date_range_start }} ]]
and [[ measured_date <= {{date_range_end }} ]]
order by 1
