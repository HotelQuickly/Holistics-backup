#standardsql
WITH rategain_data AS (
  SELECT
    hq_hotel_id,
    avg(median_percent_diff) as avg_median_percent_diff,
    AVG(avg_percent_diff) as avg_avg_percent_diff,
    COUNT(
      CASE WHEN median_percent_diff < 0 THEN median_percent_diff END
    ) / COUNT(median_percent_diff) as rategain_bp,
    COUNT(median_percent_diff) as number_of_shows
  FROM
    `rategain.daily_price_comp_*`
  where 1=1
  and [[ report_date >= {{ date_range_start }} ]]
  and [[ report_date <= {{ date_range_end }} ]]
  and [[ hotel_name in ( {{ hotel_name_rategain_ }} ) ]]
  and [[ hq_hotel_id in ( {{ rategain_hotel_id  }})]]
GROUP BY 1
HAVING number_of_shows > 20
)
,
med_median_diff as
(
select
`rategain.daily_price_comp_*`.hq_hotel_id,
percentile_cont(median_percent_diff , 0.5) over (partition by `rategain.daily_price_comp_*`.hq_hotel_id ) as median_median_percent_diff
from `rategain.daily_price_comp_*`
inner join rategain_data
on 1=1
and `rategain.daily_price_comp_*`.hq_hotel_id = rategain_data.hq_hotel_id
)
,
gbv_rank as
(
select
`analyst.all_orders`.hotel_id ,
sum(m07_selling_price_total_usd ) as GBV,
rank() over (order by sum(m07_selling_price_total_usd ) desc) as rnk
from
`analyst.all_orders`
where 1=1
and [[ date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
and [[ date(m01_order_datetime_gmt0) <= {{ date_range_end }} ]]
group by 1
)
,
ta_beat_percent AS
(
SELECT
external_id,
SAFE_DIVIDE(SUM(total_beats),SUM(total_available)) as TA_Beat_Percent_WA
FROM `metasearch_tripadvisor_report.mbl_summary_from_last_30_days` as ta_mbl
WHERE 1=1
and [[ ta_mbl.date >= {{ date_range_start }} ]]
and [[ ta_mbl.date <= {{ date_range_end }} ]]
GROUP BY 1
),
trivago_beat_percent AS
(
SELECT
partner_ref,
(SAFE_DIVIDE(SUM(beat * hotel_impr),SUM((1-unavailability)*hotel_impr))) as Trivago_Beat_Percent_WA
FROM `metasearch_trivago_report.hotel_report_from_last_30_days`  as trivago_mbl
WHERE 1=1
and [[ trivago_mbl.date >= {{ date_range_start }} ]]
and [[ trivago_mbl.date <= {{ date_range_end }} ]]
GROUP BY 1
)
SELECT
rategain_data.hq_hotel_id,
d15_hotel_name,
d10_hotel_city_name,
d12_hotel_country_name,
avg_median_percent_diff,
median_median_percent_diff,
rategain_bp,
TA_Beat_Percent_WA,
Trivago_Beat_Percent_WA,
GBV,
rnk as Rank_Based_on_GBV
FROM rategain_data
LEFT JOIN med_median_diff on 1=1
and rategain_data.hq_hotel_id = med_median_diff.hq_hotel_id
LEFT JOIN gbv_rank on 1=1
and rategain_data.hq_hotel_id = gbv_rank.hotel_id
LEFT JOIN ta_beat_percent ON 1=1
AND rategain_data.hq_hotel_id = external_id
LEFT JOIN trivago_beat_percent ON 1=1
AND rategain_data.hq_hotel_id = CAST(partner_ref as INT64)
LEFT JOIN `bi_export.hotel` ON 1=1
AND rategain_data.hq_hotel_id = `bi_export.hotel`.hotel_id
group by 1,2,3,4,5,6,7,8,9,10,11
ORDER BY avg_median_percent_diff
