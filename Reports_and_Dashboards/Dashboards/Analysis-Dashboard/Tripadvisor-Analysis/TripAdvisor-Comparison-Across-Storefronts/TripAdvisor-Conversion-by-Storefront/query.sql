#standardSQL
SELECT
Date,
sum(CASE WHEN country= 'US' THEN Conversion END) as USA,
sum(CASE WHEN country= 'AU' THEN Conversion END) as Australia,
sum(CASE WHEN country= 'JP' THEN Conversion END) as Japan,
sum(CASE WHEN country= 'IT' THEN Conversion END) as Italy,
sum(CASE WHEN country= 'FR' THEN Conversion END) as France,
sum(CASE WHEN country= 'ES' THEN Conversion END) as Spain,
sum(CASE WHEN country= 'UK' THEN Conversion END) as United_Kingdom,
sum(CASE WHEN country= 'TH' THEN Conversion END) as Thailand,
sum(CASE WHEN country= 'SG' THEN Conversion END) as Singapore,
sum(CASE WHEN country= 'IN' THEN Conversion END) as India,
sum(CASE WHEN country= 'AR' THEN Conversion END) as Argentina,
sum(CASE WHEN country= 'KR' THEN Conversion END) as Korea,
sum(CASE WHEN country= 'PH' THEN Conversion END) as Philippines
FROM
(
WITH pos_data as
(
SELECT
DATE_TRUNC(ds, {{ day_week_month|noquote }}) AS Date,
silo,
sum(clicks) as clicks,
sum(bookings) as bookings
FROM `metasearch_tripadvisor_report_raw.bmp_bucket_*`
WHERE 1=1
and _TABLE_SUFFIX >= '20170416'
and [[ ds >= {{ date_range_start }} ]]
and [[ ds <= {{ date_range_end }} ]]
and [[ SUBSTR(silo,4) IN({{ tripadvisor_device_type   }}) ]]
GROUP BY 1,2
)
SELECT
Date,
SUBSTR(silo,1,2) as country,
ROUND(100*(SAFE_DIVIDE(sum(bookings),sum(clicks))),2) as Conversion
FROM pos_data
GROUP BY 1,2
)
GROUP BY 1
