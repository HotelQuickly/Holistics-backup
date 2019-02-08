#standardSQL
SELECT
DATE_TRUNC(hotel_report.date, {{ day_week_month|noquote }}) AS Date,
SUM(hotel_impr) as Impressions,
SUM(clicks) as Clicks,
SUM(bookings) as Bookings,
SUM(gross_rev*fx_rate.currency_rate) as GBV,
SUM(cost*fx_rate.currency_rate) as Cost,
SUM(cost*fx_rate.currency_rate)/SUM(clicks) as Avg_CPC,
SUM(gross_rev*fx_rate.currency_rate)*0.108-SUM(cost*fx_rate.currency_rate)-SUM(gross_rev*fx_rate.currency_rate)*0.03 as Est_PC3,
SAFE_DIVIDE(SUM(gross_rev*fx_rate.currency_rate)*0.108-SUM(cost*fx_rate.currency_rate)-SUM(gross_rev*fx_rate.currency_rate)*0.03,SUM(gross_rev*fx_rate.currency_rate)) AS PC3_Percent_of_GBV,
(SAFE_DIVIDE(SUM(clicks),SUM(hotel_impr))) as CTR,
(SAFE_DIVIDE(SUM(bookings),SUM(clicks))) as Conversion
FROM `metasearch_trivago_report_raw.hotel_report_*` as hotel_report
LEFT JOIN hqdatawarehouse.bi_export.fx_rate ON 1=1
AND fx_rate.date = hotel_report.date
AND prim_currency_code = 'EUR'
AND scnd_currency_code = 'USD'
WHERE 1=1
and _TABLE_SUFFIX >= '20161018'
and [[ hoteL_report.date >= {{ date_range_start }} ]]
and [[ hotel_report.date <= {{ date_range_end }} ]]
and [[ pos IN ({{ trivago_storefront }}) ]]
GROUP BY 1
ORDER BY 1 DESC
