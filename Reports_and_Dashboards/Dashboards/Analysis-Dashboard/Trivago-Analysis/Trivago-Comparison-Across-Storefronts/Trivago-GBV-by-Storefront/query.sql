#standardSQL
SELECT
DATE_TRUNC(hotel_report.date, {{ day_week_month|noquote }}) AS Date,
ROUND(sum(CASE WHEN pos = 'US' THEN gross_rev*fx_rate.currency_rate  END),0) as USA,
ROUND(sum(CASE WHEN pos = 'AU' THEN gross_rev*fx_rate.currency_rate  END),0) as Australia,
ROUND(sum(CASE WHEN pos = 'DE' THEN gross_rev*fx_rate.currency_rate  END),0) as Germany,
ROUND(sum(CASE WHEN pos = 'ES' THEN gross_rev*fx_rate.currency_rate  END),0) as Spain,
ROUND(sum(CASE WHEN pos = 'CA' THEN gross_rev*fx_rate.currency_rate  END),0) as Canada,
ROUND(sum(CASE WHEN pos = 'IT' THEN gross_rev*fx_rate.currency_rate  END),0) as Italy,
ROUND(sum(CASE WHEN pos = 'UK' THEN gross_rev*fx_rate.currency_rate  END),0) as United_Kingdom,
ROUND(sum(CASE WHEN pos = 'NZ' THEN gross_rev*fx_rate.currency_rate  END),0) as New_Zealand,
ROUND(sum(CASE WHEN pos = 'FR' THEN gross_rev*fx_rate.currency_rate  END),0) as France,
ROUND(sum(CASE WHEN pos = 'IE' THEN gross_rev*fx_rate.currency_rate  END),0) as Ireland,
ROUND(sum(CASE WHEN pos = 'AT' THEN gross_rev*fx_rate.currency_rate  END),0) as Austria,
ROUND(sum(CASE WHEN pos = 'KR' THEN gross_rev*fx_rate.currency_rate  END),0) as Korea,
ROUND(sum(CASE WHEN pos = 'JP' THEN gross_rev*fx_rate.currency_rate  END),0) as Japan,
ROUND(sum(CASE WHEN pos NOT IN ('US','AU','DE','CA','IT','UK','NZ','FR','IE','AT','KR','JP','ES') THEN gross_rev*fx_rate.currency_rate  END),0) as Others
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
ORDER BY 1 ASC
