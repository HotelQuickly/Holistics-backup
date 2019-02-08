#standardSQL
WITH impressions AS
(
SELECT
DATE_TRUNC(report_date, {{ day_week_month|noquote }}) AS Date_1,
SUM(impressions) as Impressions,
SUM(single_chevron_impressions) as Single_Chevron_Impressions
FROM `metasearch_tripadvisor_report_raw.impressions_*`
where 1=1
AND _TABLE_SUFFIX >= '20170901'
and [[ report_date >= {{ date_range_start }} ]]
and [[ report_date <= {{ date_range_end }} ]]
and [[ SUBSTR(silo,1,2) IN({{  tripadvisor_storefront }}) ]]
and [[ SUBSTR(silo,4) IN({{ tripadvisor_device_type   }}) ]]
GROUP BY 1
),
other_data as
(
SELECT
DATE_TRUNC(ds, {{ day_week_month|noquote }}) AS Date_2,
SUM(gross_booking_value_usd) as GBV,
SUM(spend_usd) as Cost,
SUM(bookings) as Bookings,
SUM(clicks) as Clicks,
(SAFE_DIVIDE(SUM(bookings),SUM(clicks))) as Conversion,
(SUM(gross_booking_value_usd)*0.108 - SUM(spend_usd) - SUM(gross_booking_value_usd)*0.03) as Est_PC3,
SAFE_DIVIDE((SUM(gross_booking_value_usd)*0.0909 - SUM(spend_usd) - SUM(gross_booking_value_usd)*0.03),SUM(gross_booking_value_usd)) as PC3_Percent_of_GBV
FROM `metasearch_tripadvisor_report_raw.bmp_bucket_*`
WHERE 1=1
and _TABLE_SUFFIX >= '20170901'
and [[ ds >= {{ date_range_start }} ]]
and [[ ds <= {{ date_range_end }} ]]
and [[ SUBSTR(silo,1,2) IN({{  tripadvisor_storefront }}) ]]
and [[ SUBSTR(silo,4) IN({{ tripadvisor_device_type   }}) ]]
GROUP BY 1
ORDER BY 1 DESC
)
SELECT
other_data.Date_2 as Date,
impressions.Impressions,
impressions.Single_Chevron_Impressions,
other_data.GBV,
other_data.Cost,
other_data.Bookings,
other_data.Clicks,
other_data.Clicks/impressions.Impressions as CTR,
other_data.Conversion,
other_data.Est_PC3,
other_data.PC3_Percent_of_GBV
FROM other_data
LEFT JOIN impressions on 1=1
AND Date_1 = Date_2
ORDER BY 1 DESC
