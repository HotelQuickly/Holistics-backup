#standardsql
SELECT
  lower(source) as source,
  SUM(isac) AS isac
FROM
  `analyst.daily_isc_isac_per_source_*`
WHERE 1=1
AND [[ measured_date >= {{ date_range_start }} ]]
and [[ measured_date <= {{ date_range_end }} ]]
GROUP BY
  1
