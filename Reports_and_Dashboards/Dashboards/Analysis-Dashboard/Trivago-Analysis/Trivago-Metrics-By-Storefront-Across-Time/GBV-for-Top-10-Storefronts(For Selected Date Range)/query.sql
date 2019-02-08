#standardsql
select
pos,
SUM(bookings) as Bookings,
SUM(gross_rev*fx_rate.currency_rate) as GBV
FROM `metasearch_trivago_report_raw.hotel_report_*` as hotel_report
LEFT JOIN hqdatawarehouse.bi_export.fx_rate ON 1=1
AND fx_rate.date = hotel_report.date
AND prim_currency_code = 'EUR'
AND scnd_currency_code = 'USD'
WHERE 1=1
and _TABLE_SUFFIX >= '20161018'
and [[ hoteL_report.date >= {{ date_range_start }} ]]
and [[ hotel_report.date <= {{ date_range_end }} ]]
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10
