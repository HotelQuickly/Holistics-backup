#standardSQL
SELECT
DATE_TRUNC(hotel_report.date, {{ day_week_month|noquote }}) AS Date,
ROUND(SUM(hotel_impr),0) as Impressions,
SUM(clicks) as Clicks,
SUM(bookings) as Bookings,
ROUND(SUM(gross_rev*fx_rate.currency_rate),0) as GBV
--(cost*fx_rate.currency_rate) as Cost,
--(SUM(gross_rev*fx_rate.currency_rate)*0.108 - SUM(cost*fx_rate.currency_rate) - SUM(gross_rev*fx_rate.currency_rate)*0.03) as Estimated_PC3
FROM `metasearch_trivago_report_raw.hotel_report_*` as hotel_report
LEFT JOIN hqdatawarehouse.bi_export.fx_rate ON 1=1
AND fx_rate.date = hotel_report.date
AND prim_currency_code = 'EUR'
AND scnd_currency_code = 'USD'
WHERE 1=1
and _TABLE_SUFFIX >= '20161018'
and [[ hoteL_report.date >= {{ date_range_start }} ]]
and [[ hotel_report.date <= {{ date_range_end }} ]]
and [[ hotel_report.pos IN({{ trivago_storefront }}) ]]
and [[ hotel_report.country IN( {{ trivago_hotel_country }} ) ]]
GROUP BY 1
ORDER BY 1 DESC
