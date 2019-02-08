-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

select
beat_impr/impr as beat_percent
from
(
with tv as
(
select
date,
SUM(beat*hotel_impr) as tv_beat_impr,
SUM((1-unavailability)*hotel_impr) as tv_available_impr
from
`metasearch_trivago_report_raw.hotel_report_*`
where
hotel_impr is not null
group by 1
)
,
ta as
(
select
date,
sum(total_beats) as ta_beat_impr,
sum(total_available) as ta_available_impr
from
`metasearch_tripadvisor_report_raw.mbl_summary_*`
where
total_beats is not null
and total_available is not null
group by 1
)
select
tv.date as dt,
(tv_beat_impr + ta_beat_impr) as beat_impr,
(tv_available_impr + ta_available_impr) as impr
from
tv
left join
ta
on 1=1
and tv.date = ta.date
order by 1 desc
)
where {{time_where}}
