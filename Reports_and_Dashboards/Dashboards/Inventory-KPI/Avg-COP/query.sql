#standardsql
select measured_date,
sum(case when source = 'agodaparser01' then avg_cop end) as agodaparser,
sum(case when source = 'dotw01' then avg_cop end) as dotw,
sum(case when source = 'expedia01' then avg_cop end) as expedia,
sum(case when source = 'gta01' then avg_cop end) as gta,
sum(case when source = 'hotelbeds01' then avg_cop end) as hotelbeds,
sum(case when source = 'hq01' then avg_cop end) as hq,
sum(case when source = 'siteminder01' then avg_cop end) as siteminder,
sum(case when source = 'zumata01' then avg_cop end) as zumata
--avg(case when source NOT IN ('zumata','siteminder','hq','hotelbeds','gta','gta','expedia','dotw','agodaparser') then avg_cop end) as others
FROM(
select
measured_date,
lower(source) as source,
avg (cop) as avg_cop
from `inventory_raw.inventory_search_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_ADD(CURRENT_DATE, INTERVAL -14 DAY))
AND measured_date >= DATE_ADD(current_date, INTERVAL -14 day)
and (cgp/nights_group) <= 2000
and (cgp/nights_group) >= 5
group by 1, 2
)
group by 1
order by 1;
