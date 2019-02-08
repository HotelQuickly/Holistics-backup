#standardsql
with
cop_15 as
(
select
  report_date,
  avg(cop_night_search) as avg_cop_15_days
from `inventory.avg_cop_15_*`
group by 1
order by 1
),

cop_30 as
(
select
  report_date,
  avg(cop_night_search) as avg_cop_30_days
from `inventory.avg_cop_30_*`
group by 1
order by 1
)

select
  a.report_date,
  avg_cop_15_days,
  avg_cop_30_days
from cop_15 a
join cop_30 b
on a.report_date = b.report_date
order by 1
