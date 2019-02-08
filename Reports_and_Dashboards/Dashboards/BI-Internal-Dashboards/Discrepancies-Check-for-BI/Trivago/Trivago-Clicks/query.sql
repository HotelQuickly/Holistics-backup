#standardsql
with
log_booking_tbl as
(
  select
    date(time) date,
    count(distinct session_id) as session_id,
    count(distinct req_id) as req_id
  from `metasearch.log_availability`
  where consumer_code = 'trivago'
  group by 1
  order by 1
),
trivago_report_tbl as
(
  select
    date date,
    sum(clicks) as trivago_report_clicks
  from `metasearch_trivago_report_raw.hotel_report_*`
  where _TABLE_SUFFIX <= format_date("%Y%m%d", current_Date())
  group by 1
  order by 1
)
select
  a.date,
  session_id,
  req_id,
  trivago_report_clicks
from trivago_report_tbl a
left join log_booking_tbl b
on a.date = b.date
where 1=1
[[ and a.date >= {{ date_range_start }} ]]
[[ and a.date <=  {{ date_range_end }}  ]]
order by 1
