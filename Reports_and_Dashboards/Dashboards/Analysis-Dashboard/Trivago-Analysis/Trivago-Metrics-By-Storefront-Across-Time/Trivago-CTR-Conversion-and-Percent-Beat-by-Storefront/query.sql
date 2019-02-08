#standardSQL
SELECT
  DATE_TRUNC(date, {{ day_week_month|noquote }}) AS Date,
  ROUND(100*(SAFE_DIVIDE(SUM(clicks),SUM(hotel_impr))),3) as CTR,
  ROUND(100*(SAFE_DIVIDE(SUM(bookings),SUM(clicks))),2) as Conversion,
  ROUND(100*(SAFE_DIVIDE(SUM(beat * hotel_impr),SUM((1-unavailability)*hotel_impr))),2) as Percent_Beat
FROM `metasearch_trivago_report_raw.hotel_report_*`
WHERE 1=1
  and _TABLE_SUFFIX >= '20161018'
  and [[ date >= {{ date_range_start }} ]]
  and [[ date <= {{ date_range_end }} ]]
  and [[ pos IN({{ trivago_storefront }}) ]]
  and [[ country IN( {{ trivago_hotel_country }} ) ]]
GROUP BY 1
ORDER BY 1 ASC
