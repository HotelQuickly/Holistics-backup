#standardSQL
SELECT
date as Date,
SUM(CASE WHEN lower(consumer_code) = 'trivago' THEN tsc END) as trivago,
SUM(CASE WHEN lower(consumer_code) = 'tripadvisor' THEN tsc END) as tripadvisor,
SUM(CASE WHEN lower(consumer_code) = 'hotelscombined' THEN tsc END) as hotelscombined,
SUM(CASE WHEN lower(consumer_code) = 'kayak' THEN tsc END) as kayak,
SUM(CASE WHEN lower(consumer_code) = 'skyscanner' THEN tsc END) as skyscanner,
SUM(CASE WHEN lower(consumer_code) = 'hotellook' THEN tsc END) as hotellook
FROM `hqdatawarehouse.analyst.daily_tsc_tsac_*`
WHERE 1=1
[[ and date >= {{ date_range_start }} ]]
[[ and date <=  {{ date_range_end }}  ]]
GROUP BY 1
ORDER BY 1 ASC
