#standardsql
SELECT
Date,
ROUND(SUM(CASE WHEN Channel = 'trivago' THEN Error_Rate END)*100,2) as trivago,
ROUND(SUM(CASE WHEN Channel = 'tripadvisor' THEN Error_Rate END)*100,2) as tripadvisor,
ROUND(SUM(CASE WHEN Channel = 'hotelscombined' THEN Error_Rate END)*100,2) as hotelscombined,
ROUND(SUM(CASE WHEN Channel = 'skyscanner' THEN Error_Rate END)*100,2) as skyscanner,
ROUND(SUM(CASE WHEN Channel = 'kayak' THEN Error_Rate END)*100,2) as kayak
FROM
(
SELECT
date(time) as Date,
consumer_code as Channel,
count (distinct case when errors is not null then req_id END )
/ count (distinct req_id) AS Error_Rate
FROM
metasearch.log_availability
WHERE 1=1
[[ and date(time) >= {{ date_range_start }} ]]
[[ and date(time) <=  {{ date_range_end }}  ]]
group by 1,2
)
GROUP BY 1
ORDER BY 1 ASC
