#standardSQL
With hotel_rank AS
(
SELECT
hotel_id,
d15_hotel_name,
SUM(m07_selling_price_total_usd) as GBV,
sum(case when lower(d180_order_referral_source_code) = 'trivago' then m07_selling_price_total_usd end) tv_gbv,
sum(case when lower(d180_order_referral_source_code) = 'tripadvisor' then m07_selling_price_total_usd end) ta_gbv,
RANK() OVER (ORDER BY SUM(m07_selling_price_total_usd) DESC) rank_of_hotel,
COUNT(distinct order_id) as Bookings,
count(distinct case when lower(d180_order_referral_source_code) = 'trivago' then order_id end) tv_b,
count(distinct case when lower(d180_order_referral_source_code) = 'tripadvisor' then order_id end) ta_b
FROM `hqdatawarehouse.analyst.all_orders`
WHERE 1=1
AND date(m01_order_datetime_gmt0) >= DATE_ADD(date_add(current_date, interval -1 day), INTERVAL -30 day)
GROUP BY 1,2
ORDER BY GBV DESC
),

ta_beat_percent AS
(
SELECT
external_id,
SAFE_DIVIDE(SUM(total_beats),SUM(total_available)) as TA_Beat_Percent_WA
FROM `hqdatawarehouse.metasearch_tripadvisor_report_raw.mbl_summary_*` as ta_mbl
WHERE ta_mbl.date >= DATE_ADD(current_date, INTERVAL -30 day)
GROUP BY 1
),

trivago_beat_percent AS
(
SELECT
partner_ref,
(SAFE_DIVIDE(SUM(beat * hotel_impr),SUM((1-unavailability)*hotel_impr))) as Trivago_Beat_Percent_WA
FROM `hqdatawarehouse.metasearch_trivago_report_raw.hotel_report_*`  as trivago_mbl
WHERE trivago_mbl.date >= DATE_ADD(current_date, INTERVAL -30 day)
GROUP BY 1
),

rategain_data AS
(
SELECT
hq_hotel_id,
AVG(case when channel='trivago' then cheapest_price_on_channel end) as rategain_cheapest_rate_tv,
AVG(case when channel='tripadvisor' then cheapest_price_on_channel end) as rategain_cheapest_rate_ta,
avg(average_price) as avg_hq_price,
avg(median_price) as median_hq_price,
--avg(median_percent_diff) as avg_median_percent_diff,
--AVG(avg_percent_diff) as avg_avg_percent_diff,
safe_divide(COUNT(CASE WHEN average_price < cheapest_price_on_channel and channel = 'trivago' THEN hq_hotel_id END),
  COUNT(case when channel = 'trivago' then hq_hotel_id end)) as tv_rategain_bp,
safe_divide(COUNT(CASE WHEN average_price < cheapest_price_on_channel and channel = 'tripadvisor' THEN hq_hotel_id END),
  COUNT(case when channel = 'tripadvisor' then hq_hotel_id end)) as ta_rategain_bp,
COUNT(hq_hotel_id) as number_of_shows
FROM `hqdatawarehouse.rategain.daily_price_comp_*`
GROUP BY 1
HAvING number_of_shows > 30
),

final as
(
SELECT
ht_table.hotel_id,
ht_table.d15_hotel_name,
rank_of_hotel,
round(GBV,0) GBV,
round(ta_gbv,0) ta_gbv,
round(tv_gbv,0) tv_gbv,
Bookings,
ta_b ta_booking,
tv_b tv_booking,
round(avg_hq_price,0) avg_hq_price,
-- round(median_hq_price,0) median_hq_price,
round(rategain_cheapest_rate_tv,0) rategain_cheapest_rate_tv,
round(tv_rategain_bp,8) tv_rategain_bp,
round(Trivago_Beat_Percent_WA,8) Trivago_Beat_Percent_WA,
round(rategain_cheapest_rate_ta,0) rategain_cheapest_rate_ta,
round(ta_rategain_bp,8) ta_rategain_bp,
round(TA_Beat_Percent_WA,8) TA_Beat_Percent_WA
-- number_of_shows,
FROM rategain_data
LEFT JOIN ta_beat_percent ON 1=1
AND rategain_data.hq_hotel_id = external_id
LEFT JOIN trivago_beat_percent ON 1=1
AND CAST(rategain_data.hq_hotel_id as STRING) = partner_ref
LEFT JOIN hotel_rank On 1=1
AND hq_hotel_id = hotel_id
LEFT JOIN hqdatawarehouse.bi_export.hotel as ht_table ON 1=1
AND hq_hotel_id = ht_table.hotel_id
ORDER BY GBV DESC
)

select * from final
where rank_of_hotel <= 200
order by GBV desc
