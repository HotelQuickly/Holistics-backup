#standardsql
SELECT
date(time) as Date,
ROUND((count (distinct case when errors is not null then req_id END )
/ count (distinct req_id)) * 100,2) AS Error_Rate
FROM
metasearch.log_availability
WHERE 1=1
[[ and date(time) >= {{ date_range_start }} ]]
[[ and date(time) <=  {{ date_range_end }}  ]]
group by 1
order by 1
