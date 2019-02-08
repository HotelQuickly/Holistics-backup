-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

select
meet_impr/impr as meet_percent
from
(
with tv as
(
select
date,
SUM(meet*hotel_impr) as tv_meet_impr,
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
sum(total_meets) as ta_meet_impr,
sum(total_available) as ta_available_impr
from
`metasearch_tripadvisor_report_raw.mbl_summary_*`
where
total_meets is not null
and total_available is not null
group by 1
)
select
tv.date as dt,
(tv_meet_impr + ta_meet_impr) as meet_impr,
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
