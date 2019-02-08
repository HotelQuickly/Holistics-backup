#standardSQL
select
date,
lower(consumer_code) as channel,
sum(tsc) as tsc
from
`analyst.daily_tsc_tsac_*`
where
[[ date >= {{ date_range_start }} ]]
[[ and date <=  {{ date_range_end }}  ]]
group by 1,2
order by 1 asc
