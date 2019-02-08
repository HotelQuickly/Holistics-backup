#standardSQL
SELECT
DATE_TRUNC(ds, {{ day_week_month|noquote }}) AS Date,
sum(CASE WHEN SUBSTR(silo,1,2) = 'US' THEN gross_booking_value_usd END) as USA,
sum(CASE WHEN SUBSTR(silo,1,2) = 'AU' THEN gross_booking_value_usd END) as Australia,
sum(CASE WHEN SUBSTR(silo,1,2) = 'JP' THEN gross_booking_value_usd END) as Japan,
sum(CASE WHEN SUBSTR(silo,1,2) = 'IT' THEN gross_booking_value_usd END) as Italy,
sum(CASE WHEN SUBSTR(silo,1,2) = 'ES' THEN gross_booking_value_usd END) as Spain,
sum(CASE WHEN SUBSTR(silo,1,2) = 'FR' THEN gross_booking_value_usd END) as France,
sum(CASE WHEN SUBSTR(silo,1,2) = 'DE' THEN gross_booking_value_usd END) as Germany,
sum(CASE WHEN SUBSTR(silo,1,2) = 'UK' THEN gross_booking_value_usd END) as United_Kingdom,
sum(CASE WHEN SUBSTR(silo,1,2) = 'TH' THEN gross_booking_value_usd END) as Thailand,
sum(CASE WHEN SUBSTR(silo,1,2) = 'SG' THEN gross_booking_value_usd END) as Singapore,
sum(CASE WHEN SUBSTR(silo,1,2) = 'IN' THEN gross_booking_value_usd END) as India,
sum(CASE WHEN SUBSTR(silo,1,2) = 'KR' THEN gross_booking_value_usd END) as Korea,
sum(CASE WHEN SUBSTR(silo,1,2) = 'PH' THEN gross_booking_value_usd END) as Philippines
FROM `metasearch_tripadvisor_report_raw.bmp_bucket_*`
WHERE 1=1
and _TABLE_SUFFIX >= '20170416'
and [[ ds >= {{ date_range_start }} ]]
and [[ ds <= {{ date_range_end }} ]]
and [[ SUBSTR(silo,4) IN({{ tripadvisor_device_type   }}) ]]
GROUP BY 1
ORDER BY 1 ASC
