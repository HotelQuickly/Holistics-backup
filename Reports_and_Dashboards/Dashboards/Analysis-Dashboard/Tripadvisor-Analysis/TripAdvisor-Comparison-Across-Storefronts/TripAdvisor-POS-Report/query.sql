#standardSQL
with cc as
(
select
case when country_code = 'GB' then 'UK' else country_code end as country_code,
case when country_name = 'Netherlands' then 'The Netherlands' else country_name end as country_name
from
`bi_export.lst_destination`
group by 1,2
order by 2
)
,
beat_country as
(
select
case when traffic_type = 'Desktop' then 'DMeta' else traffic_type end as traffic_type,
country,
country_code,
sum(total_beats) as beats,
sum(total_available) as available,
sum(total_requests) as requests
from
`metasearch_tripadvisor_report_raw.mbl_summary_*`
inner join
cc
on 1=1
and country = country_name
where 1=1
and _table_suffix >= '20170901'
and [[ date >= {{ date_range_start }} ]]
and [[ date <= {{ date_range_end }} ]]
group by 1,2,3
order by 1
),
beat as
(
select
concat(country_code,"-",traffic_type) as silos,
safe_divide(beats, available) as beat_percent_when_available,
safe_divide(beats, requests) as beat_percent_in_general
from
beat_country
group by 1,2,3
),
impressions AS
(
SELECT
silo,
SUM(impressions) as Impressions,
SUM(single_chevron_impressions) as Single_Chevron_Impressions
FROM `metasearch_tripadvisor_report_raw.impressions_*`
where 1=1
AND _TABLE_SUFFIX >= '20170901'
and [[ report_date >= {{ date_range_start }} ]]
and [[ report_date <= {{ date_range_end }} ]]
GROUP BY 1
)
SELECT
report.silo as Storefront,
impressions.Impressions,
impressions.Single_Chevron_Impressions,
SUM(gross_booking_value_usd) as GBV,
SUM(spend_usd) as Cost,
SUM(bookings) as Bookings,
SUM(clicks) as Clicks,
SUM(clicks)/impressions.Impressions as CTR,
(SAFE_DIVIDE(SUM(bookings),SUM(clicks))) as Conversion,
SUM(gross_booking_value_usd)*0.108 - SUM(spend_usd) - SUM(gross_booking_value_usd)*0.03 as Est_PC3,
SAFE_DIVIDE((SUM(gross_booking_value_usd)*0.0909 - SUM(spend_usd) - SUM(gross_booking_value_usd)*0.03),SUM(gross_booking_value_usd)) as PC3_as_a_Percent_GBV,

--SAFE_DIVIDE(SUM(gross_booking_value_usd), SUM(spend_usd)) as ROAS2,
--SAFE_DIVIDE((SUM(gross_booking_value_usd)*0.108) - SUM(spend_usd), SUM(spend_usd)) as ROI,
beat.beat_percent_when_available as Beat_Percent_When_Available,
beat.beat_percent_in_general as Beat_Percent
FROM `metasearch_tripadvisor_report_raw.bmp_bucket_*` as report
left join beat on 1=1
and silos = silo
left join impressions ON 1=1
and report.silo = impressions.silo
WHERE 1=1
and _TABLE_SUFFIX >= '20170901'
and [[ ds >= {{ date_range_start }} ]]
and [[ ds <= {{ date_range_end }} ]]
GROUP BY 1,2,3,12,13
ORDER BY GBV DESC
