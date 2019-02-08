#standardSQL
SELECT
measured_date,
hq_hotel_id,
days_in_advance_group,
SUM(tsac)/SUM(tsc) as availability
FROM `inventory_raw.total_search_*`
WHERE 1=1
AND _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_ADD(CURRENT_DATE, INTERVAL -14 DAY))
and date_diff(current_date, measured_date, day) <= 14
and [[ cast(hq_hotel_id as string) in ({{ hotel_id_test }}) ]]
GROUP BY 1,2,3
ORDER BY 1, 3
