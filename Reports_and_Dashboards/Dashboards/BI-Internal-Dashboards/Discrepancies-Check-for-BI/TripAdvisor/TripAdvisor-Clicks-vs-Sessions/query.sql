#standardsql
with
log_booking_tbl as
(
  select
    date(time) date,
    count(distinct session_id) as session_id,
    count(distinct req_id) as req_id
  from `metasearch.log_availability`
  where consumer_code = 'tripadvisor'
  group by 1
  order by 1
),
ta_report_tbl as
(
  select
    ds date,
    sum(clicks) as ta_report_clicks
  from `metasearch_tripadvisor_report_raw.bmp_bucket_*`
  where _TABLE_SUFFIX <= format_date("%Y%m%d", current_Date())
  group by 1
  order by 1
)
select
  a.date,
  session_id,
  req_id,
  ta_report_clicks
from ta_report_tbl a
left join log_booking_tbl b
on a.date = b.date
where 1=1
[[ and a.date >= {{ date_range_start }} ]]
[[ and a.date <=  {{ date_range_end }}  ]]
order by 1
