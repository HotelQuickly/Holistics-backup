#standardSQL
SELECT
date(log_availability_view.time) as date,
COUNT(DISTINCT CASE WHEN consumer_code = 'kayak' THEN session_id END) as kayak,
COUNT(DISTINCT CASE WHEN consumer_code = 'skyscanner' THEN session_id END) as skyscanner,
COUNT(DISTINCT CASE WHEN consumer_code = 'hotelscombined' THEN session_id END) as hotelscombined,
COUNT(DISTINCT CASE WHEN consumer_code = 'trivago' THEN req_id END) as trivago,
COUNT(DISTINCT CASE WHEN consumer_code = 'tripadvisor' THEN session_id END) as tripadvisor
FROM metasearch.log_availability_view
WHERE 1=1
[[ and date(time) >= {{ date_range_start }} ]]
[[ and date(time) <=  {{ date_range_end }}  ]]
GROUP BY 1
ORDER BY 1 ASC
