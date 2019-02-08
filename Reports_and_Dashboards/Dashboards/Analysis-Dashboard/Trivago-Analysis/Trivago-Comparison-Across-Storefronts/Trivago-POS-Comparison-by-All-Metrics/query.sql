#standardSQL
with commission_tbl as
(
SELECT
d57_user_base_country_code as country_code,
d58_user_base_country_name as user_country,
sum(m12_amount_of_commission_earned_usd) as Commission,
sum(m07_selling_price_total_usd) as Internal_GBV,
count(distinct order_id) AS Internal_Bookings
FROM analyst.all_orders a
WHERE 1=1
AND lower(d180_order_referral_source_code) = 'trivago'
[[ AND Date(m01_order_datetime_gmt0) >= {{ date_range_start }}]]
[[ AND Date(m01_order_datetime_gmt0) <= {{ date_range_end }}]]
group by 1,2
),

tr_report as
(
SELECT
pos as Storefront,
SUM(hotel_impr) as Impressions,
SUM(clicks) as Clicks,
SUM(bookings) as Trivago_Bookings,
SUM(gross_rev*fx_rate.currency_rate) as Trivago_GBV,
SUM(cost*fx_rate.currency_rate) as Cost,
SAFE_DIVIDE(SUM(cost*fx_rate.currency_rate), SUM(gross_rev*fx_rate.currency_rate)) As Actual_CPA,
-- SAFE_DIVIDE(SUM(cost*fx_rate.currency_rate),SUM(bookings)) as CPA_Targets, -- not needed as of 01/08/2018
SUM(cost*fx_rate.currency_rate) + SUM(gross_rev*fx_rate.currency_rate)*0.03 as Total_Cost,
(SAFE_DIVIDE(SUM(clicks),SUM(hotel_impr))) as CTR,
(SAFE_DIVIDE(SUM(bookings),SUM(clicks))) as Conversion,
(SAFE_DIVIDE(SUM(beat * hotel_impr),SUM((1-unavailability)*hotel_impr))) as Percent_Beat,
-1*(SAFE_DIVIDE(SUM(1 - (unavailability * hotel_impr)),SUM(hotel_impr))) as Availability
FROM `metasearch_trivago_report_raw.hotel_report_*` as hotel_report
LEFT JOIN hqdatawarehouse.bi_export.fx_rate ON 1=1
AND fx_rate.date = hotel_report.date
AND prim_currency_code = 'EUR'
AND scnd_currency_code = 'USD'
WHERE 1=1
and _TABLE_SUFFIX >= '20161018'
and [[ hotel_report.date >= {{ date_range_start }} ]]
and [[ hotel_report.date <= {{ date_range_end }} ]]
GROUP BY 1
ORDER BY Trivago_GBV DESC
),

final as
(
select
Storefront,
Impressions,
Clicks,
Trivago_Bookings,
Internal_Bookings,
Trivago_GBV,
Internal_GBV,
Commission,
Cost,
Actual_CPA,
-- CPA_Targets,
-- Commission - Total_Cost as PC3, -- Remove PC3 as metric
-- SAFE_DIVIDE((Commission - Total_Cost), GBV) as PC3_as_a_Percent_of_GBV,
Commission - Cost as Profit, -- Needed for Ben
SAFE_DIVIDE((Commission - Cost), Cost) as ROI, -- Needed for Ben
SAFE_DIVIDE(Commission, Cost) as ROAS,
SAFE_DIVIDE(SAFE_DIVIDE(Commission, Cost), 10) * SAFE_DIVIDE((Commission - Cost), Cost) as ben_metric,
CTR,
Conversion,
Percent_Beat,
Availability
from tr_report tr
left join commission_tbl c
on 1=1
and tr.Storefront = c.country_code
order by Trivago_GBV desc
)

select * from final
