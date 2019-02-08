#standardsql
select Date,
--sum(case when source = 'agodaparser01' then error_requests end) as agodaparser,
sum(case when source = 'dotw01' then error_requests end)/sum(case when source = 'dotw01' then requests end) as dotw,
sum(case when source = 'expedia01' then error_requests end)/sum(case when source = 'expedia01' then requests end) as expedia,
--sum(case when source = 'gta01' then error_requests end)/sum(case when source = 'gta01' then requests end) as gta,
--sum(case when source = 'hotelbeds01' then error_requests end)/sum(case when source = 'hotelbeds01' then requests end) as hotelbeds,
--sum(case when source = 'gta03' then error_requests end)/sum(case when source = 'gta03' then requests end) as gta03,
sum(case when source = 'hq01' then error_requests end)/sum(case when source = 'hq01' then requests end) as hq,
sum(case when source = 'siteminder01' then error_requests end)/sum(case when source = 'siteminder01' then requests end) as siteminder,
sum(case when source = 'zumata01' then error_requests end)/sum(case when source = 'zumata01' then requests end) as zumata,
sum(case when source NOT IN ('hq','siteminder','expedia01','dotw01','zumata') then error_requests end)/sum(case when source NOT IN ('hq','siteminder','expedia01','dotw01','zumata') then requests end) as others
FROM
(
SELECT
date(time) as Date,
lower(source_code) as source,
count (distinct case when errors is not null then req_id END ) as error_requests,
count (distinct req_id) AS requests
FROM
metasearch.log_booking
WHERE 1=1
[[ and date(time) >= {{ date_range_start }} ]]
[[ and date(time) <=  {{ date_range_end }}  ]]
group by 1,2
)
group by 1
order by 1
