#standardSQL
SELECT
date as Date,
ROUND((SUM(CASE WHEN lower(consumer_code) = 'trivago' THEN tsac END)/
SUM(CASE WHEN lower(consumer_code) = 'trivago' THEN tsc END))*100,2) as trivago,
ROUND((SUM(CASE WHEN lower(consumer_code) = 'tripadvisor' THEN tsac END)/
SUM(CASE WHEN lower(consumer_code) = 'tripadvisor' THEN tsc END))*100,2) as tripadvisor,
ROUND((SUM(CASE WHEN lower(consumer_code) = 'hotelscombined' THEN tsac END)/
SUM(CASE WHEN lower(consumer_code) = 'hotelscombined' THEN tsc END))*100,2) as hotelscombined,
ROUND((SUM(CASE WHEN lower(consumer_code) = 'skyscanner' THEN tsac END)/
SUM(CASE WHEN lower(consumer_code) = 'skyscanner' THEN tsc END))*100,2) as skyscanner,
ROUND((SUM(CASE WHEN lower(consumer_code) = 'kayak' THEN tsac END)/
SUM(CASE WHEN lower(consumer_code) = 'kayak' THEN tsc END))*100,2) as kayak,
ROUND((SUM(CASE WHEN lower(consumer_code) = 'hotellook' THEN tsac END)/
SUM(CASE WHEN lower(consumer_code) = 'hotellook' THEN tsc END))*100,2) as hotellook
FROM `hqdatawarehouse.analyst.daily_tsc_tsac_*`
WHERE 1=1
[[ and date >= {{ date_range_start }} ]]
[[ and date <=  {{ date_range_end }}  ]]
GROUP BY 1
ORDER BY 1 ASC
