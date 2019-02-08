#standardSQL
SELECT
DATE_TRUNC(ds, {{ day_week_month|noquote }}) AS Date,
SUM(gross_booking_value_usd) as GBV,
SUM(bookings) as Bookings,
SUM(clicks) as Clicks
FROM `metasearch_tripadvisor_report_raw.bmp_bucket_*`
WHERE 1=1
and _TABLE_SUFFIX >= '20170901'
and [[ ds >= {{ date_range_start }} ]]
and [[ ds <= {{ date_range_end }} ]]
and [[ SUBSTR(silo,1,2) IN({{  tripadvisor_storefront }}) ]]
and [[ SUBSTR(silo,4) IN({{ tripadvisor_device_type   }}) ]]
GROUP BY 1
ORDER BY 1 ASC
