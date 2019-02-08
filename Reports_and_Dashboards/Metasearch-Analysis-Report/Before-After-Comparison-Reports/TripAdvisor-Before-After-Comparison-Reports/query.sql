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
),

beat_country_bf as
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
and [[ date >= {{ date_range_before_start }} ]]
and [[ date <= {{ date_range_before_end }} ]]
group by 1,2,3
order by 1
),

beat_country_af as
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

beat_bf as
(
select
concat(country_code,"-",traffic_type) as silos,
safe_divide(beats, available) as beat_percent_when_available,
safe_divide(beats, requests) as beat_percent_in_general
from
beat_country_bf
group by 1,2,3
),

beat_af as
(
select
concat(country_code,"-",traffic_type) as silos,
safe_divide(beats, available) as beat_percent_when_available,
safe_divide(beats, requests) as beat_percent_in_general
from
beat_country_af
group by 1,2,3
),

impressions_bf AS
(
SELECT
silo,
SUM(impressions) as Impressions,
SUM(single_chevron_impressions) as Single_Chevron_Impressions
FROM `metasearch_tripadvisor_report_raw.impressions_*`
where 1=1
AND _TABLE_SUFFIX >= '20170901'
and [[ report_date >= {{ date_range_before_start }} ]]
and [[ report_date <= {{ date_range_before_end }} ]]
GROUP BY 1
),

impressions_af AS
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
),

final_bf as
(
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
safe_divide(sum(gross_booking_value_usd),sum(spend_usd)) as ROAS,
beat.beat_percent_when_available as Beat_Percent_When_Available,
beat.beat_percent_in_general as Beat_Percent
FROM `metasearch_tripadvisor_report_raw.bmp_bucket_*` as report
left join beat_bf beat on 1=1
and silos = silo
left join impressions_bf impressions ON 1=1
and report.silo = impressions.silo
WHERE 1=1
and _TABLE_SUFFIX >= '20170901'
and [[ ds >= {{ date_range_before_start }} ]]
and [[ ds <= {{ date_range_before_end }} ]]
GROUP BY 1,2,3,11,12
ORDER BY GBV DESC
),

final_af as
(
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
safe_divide(sum(gross_booking_value_usd),sum(spend_usd)) as ROAS,
beat.beat_percent_when_available as Beat_Percent_When_Available,
beat.beat_percent_in_general as Beat_Percent
FROM `metasearch_tripadvisor_report_raw.bmp_bucket_*` as report
left join beat_af beat on 1=1
and silos = silo
left join impressions_af impressions ON 1=1
and report.silo = impressions.silo
WHERE 1=1
and _TABLE_SUFFIX >= '20170901'
and [[ ds >= {{ date_range_start }} ]]
and [[ ds <= {{ date_range_end }} ]]
GROUP BY 1,2,3,11,12
ORDER BY GBV DESC
)

select
  bf.Storefront,
  bf.Impressions as Impressions_before,
  af.Impressions as Impressions_after,
  safe_divide((af.Impressions-bf.Impressions), bf.Impressions) as Impressions_change,
  bf.Single_Chevron_Impressions as Single_Chevron_Impressions_before,
  af.Single_Chevron_Impressions aS Single_Chevron_Impressions_after,
  safe_divide((af.Single_Chevron_Impressions-bf.Single_Chevron_Impressions), bf.Single_Chevron_Impressions) as Single_Chevron_Impressions_change,
  bf.GBV as GBV_before,
  af.GBV as GBV_after,
  safe_divide((af.GBV-bf.GBV), bf.GBV) as GBV_change,
  bf.Cost as Cost_before,
  af.Cost as Cost_after,
  safe_divide((af.Cost-bf.Cost), bf.Cost) as Cost_change,
  bf.Bookings as Bookings_before,
  af.Bookings as Bookings_after,
  safe_divide((af.Bookings-bf.Bookings), bf.Bookings) as Bookings_change,
  bf.Clicks as Clicks_before,
  af.Clicks as Clicks_after,
  safe_divide((af.Clicks-bf.Clicks), bf.Clicks) as Clicks_change,
  bf.CTR as CTR_before,
  af.CTR as CTR_after,
  safe_divide((af.CTR-bf.CTR), bf.CTR) as CTR_change,
  bf.Conversion as Conversion_before,
  af.Conversion as Conversion_after,
  safe_divide((af.Conversion-bf.Conversion), bf.Conversion) as Conversion_change,
  bf.ROAS as ROAS_before,
  af.ROAS as ROAS_after,
  safe_divide((af.ROAS-bf.ROAS), bf.ROAS) as ROAS_change,
  bf.Beat_Percent_When_Available as Beat_Percent_When_Available_before,
  af.Beat_Percent_When_Available as Beat_Percent_When_Available_after,
  safe_divide((af.Beat_Percent_When_Available-bf.Beat_Percent_When_Available), bf.Beat_Percent_When_Available) as Beat_Percent_When_Available_change,
  bf.Beat_Percent as Beat_Percent_before,
  af.Beat_Percent as Beat_Percent_after,
  safe_divide((af.Beat_Percent-bf.Beat_Percent), bf.Beat_Percent) as Beat_Percent_change
from final_bf bf
join final_af af
on 1=1
and bf.Storefront = af.Storefront
order by GBV_after desc
