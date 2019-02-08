#standardSQL
SELECT
DATE_TRUNC(date(time), {{ day_week_month|noquote }}) AS Date,
consumer_code as Channel,
COUNT(DISTINCT session_id) as Sessions
FROM `metasearch.log_availability`
WHERE 1=1
AND [[ date(time) >= {{ date_range_start }} ]]
AND [[ date(time) <= {{ date_range_end }} ]]
AND [[ consumer_code = {{ consumer_code }} ]]
GROUP BY 1,2
ORDER BY 1 ASC
