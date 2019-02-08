#standardSQL
SELECT
date as Date,
trivago_clicks as trivago,
ta_clicks as tripadvisor
FROM analyst.ta_trivago_daily_report_data
WHERE 1=1
[[ and date >= {{ date_range_start }} ]]
[[ and date <=  {{ date_range_end }}  ]]
ORDER BY Date ASC
