#standardsql
SELECT date,
sum(total_beats) / sum(total_available) as beat_percent_when_available
FROM `metasearch_tripadvisor_report_raw.mbl_summary_*`
where 1=1
AND _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_ADD(CURRENT_DATE, INTERVAL -90 DAY))
and [[ date >= {{ date_range_start }} ]]
and [[ date <= {{ date_range_end }}  ]]
GROUP BY 1;
