#standardSQL
SELECT
DATE_TRUNC(date, {{ day_week_month|noquote }}) AS Date,
SUM(CASE WHEN country = 'US' THEN Conversion END) as USA,
SUM(CASE WHEN country = 'AU' THEN Conversion END) as Australia,
SUM(CASE WHEN country = 'DE' THEN Conversion END) as Germany,
SUM(CASE WHEN country = 'CA' THEN Conversion END) as Canada,
SUM(CASE WHEN country = 'IT' THEN Conversion END) as Italy,
SUM(CASE WHEN country = 'UK' THEN Conversion END) as United_Kingdom,
SUM(CASE WHEN country = 'NZ' THEN Conversion END) as New_Zealand,
SUM(CASE WHEN country = 'FR' THEN Conversion END) as France,
SUM(CASE WHEN country = 'IE' THEN Conversion END) as Ireland,
SUM(CASE WHEN country = 'AT' THEN Conversion END) as Austria,
SUM(CASE WHEN country = 'KR' THEN Conversion END) as Korea,
SUM(CASE WHEN country = 'JP' THEN Conversion END) as Japan
FROM
(
WITH pos_data as
(
SELECT
DATE_TRUNC(date, {{ day_week_month|noquote }}) AS Date,
pos as country,
sum(clicks) as clicks,
sum(bookings) as bookings
FROM `metasearch_trivago_report_raw.hotel_report_*`
WHERE 1=1
and _TABLE_SUFFIX >= '20161018'
and [[ date >= {{ date_range_start }} ]]
and [[ date <= {{ date_range_end }} ]]
GROUP BY 1,2
)
SELECT
Date,
country,
CASE
WHEN country = 'US' THEN ROUND(100*(SAFE_DIVIDE(sum(bookings),sum(clicks))),2)
WHEN country = 'AU' THEN ROUND(100*(SAFE_DIVIDE(sum(bookings),sum(clicks))),2)
WHEN country = 'DE' THEN ROUND(100*(SAFE_DIVIDE(sum(bookings),sum(clicks))),2)
WHEN country = 'CA' THEN ROUND(100*(SAFE_DIVIDE(sum(bookings),sum(clicks))),2)
WHEN country = 'IT' THEN ROUND(100*(SAFE_DIVIDE(sum(bookings),sum(clicks))),2)
WHEN country = 'UK' THEN ROUND(100*(SAFE_DIVIDE(sum(bookings),sum(clicks))),2)
WHEN country = 'NZ' THEN ROUND(100*(SAFE_DIVIDE(sum(bookings),sum(clicks))),2)
WHEN country = 'FR' THEN ROUND(100*(SAFE_DIVIDE(sum(bookings),sum(clicks))),2)
WHEN country = 'IE' THEN ROUND(100*(SAFE_DIVIDE(sum(bookings),sum(clicks))),2)
WHEN country = 'AT' THEN ROUND(100*(SAFE_DIVIDE(sum(bookings),sum(clicks))),2)
WHEN country = 'KR' THEN ROUND(100*(SAFE_DIVIDE(sum(bookings),sum(clicks))),2)
WHEN country = 'JP' THEN ROUND(100*(SAFE_DIVIDE(sum(bookings),sum(clicks))),2)
WHEN country NOT IN ('US','AU','DE','CA','IT','UK','NZ','FR','IE','AT','KR','JP') THEN ROUND(100*(SAFE_DIVIDE(sum(bookings),sum(clicks))),2)
END As Conversion
FROM pos_data
GROUP BY 1,2
)
GROUP BY 1
