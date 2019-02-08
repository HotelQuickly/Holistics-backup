#standardsql
SELECT
  date,
  (SUM(beat*hotel_impr)/ SUM((1-unavailability)*hotel_impr))*100 AS beat_percent_when_available
FROM
  `metasearch_trivago_report_raw.hotel_report_*`
WHERE 1=1
  AND  hotel_impr > 0
  AND _TABLE_SUFFIX >= '20181101'
  [[ AND date >= {{ date_range_start }} ]]
  [[ AND date <=  {{ date_range_end }}  ]]
GROUP BY 1
