#standardSQL
SELECT
DATE_TRUNC(hotel_report.date, {{ day_week_month|noquote }}) AS Date,
pos as Storefront,
SUM(hotel_impr) as Impressions,
SUM(clicks) as Clicks,
SUM(bookings) as Bookings,
SUM(gross_rev*fx_rate.currency_rate) as GBV,
SUM(cost*fx_rate.currency_rate) as Cost,
(SUM(gross_rev*fx_rate.currency_rate)*0.108 - SUM(cost*fx_rate.currency_rate) - SUM(gross_rev*fx_rate.currency_rate)*0.03) as Estimated_PC3,
(SAFE_DIVIDE(SUM(clicks),SUM(hotel_impr))) as CTR,
(SAFE_DIVIDE(SUM(bookings),SUM(clicks))) as Conversion,
(SAFE_DIVIDE(SUM(beat * hotel_impr),SUM((1-unavailability)*hotel_impr))) as Percent_Beat,
-1*(SAFE_DIVIDE(SUM(1 - (unavailability * hotel_impr)),SUM(hotel_impr))) as Availability
FROM `metasearch_trivago_report_raw.hotel_report_*` as hotel_report
LEFT JOIN hqdatawarehouse.bi_export.fx_rate ON 1=1
AND fx_rate.date = hotel_report.date
AND prim_currency_code = 'EUR'
AND scnd_currency_code = 'USD'
WHERE 1=1
and _TABLE_SUFFIX >= '20161018'
and [[ hoteL_report.date >= {{ date_range_start }} ]]
and [[ hotel_report.date <= {{ date_range_end }} ]]
GROUP BY 1,2
ORDER BY 1,2
