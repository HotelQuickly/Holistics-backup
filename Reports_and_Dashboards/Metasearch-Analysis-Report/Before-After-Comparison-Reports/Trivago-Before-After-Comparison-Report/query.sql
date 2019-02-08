#standardsql
with
commission_tbl_bf AS
(
SELECT
d58_user_base_country_name as user_country,
sum(m12_amount_of_commission_earned_usd) as Commission
FROM analyst.all_orders a
WHERE 1=1
AND lower(d180_order_referral_source_code) = 'trivago'
[[ AND Date(m01_order_datetime_gmt0) >= {{ date_range_before_start }}]]
[[ AND Date(m01_order_datetime_gmt0) <= {{ date_range_before_end }}]]
group by 1
),

commission_tbl_af as
(
SELECT
d58_user_base_country_name as user_country,
sum(m12_amount_of_commission_earned_usd) as Commission
FROM analyst.all_orders a
WHERE 1=1
AND lower(d180_order_referral_source_code) = 'trivago'
[[ AND Date(m01_order_datetime_gmt0) >= {{ date_range_start }}]]
[[ AND Date(m01_order_datetime_gmt0) <= {{ date_range_end }}]]
group by 1
),

country_code_bf as
(
select
  user_country,
  (CASE WHEN country_code = 'GB' THEN 'UK' ELSE country_code END) as country_code,
  Commission
from commission_tbl_bf a
join `bi_export.lst_destination`  b
on a.user_country = b.country_name
group by 1,2,3
),

country_code_af as
(
select
  user_country,
  (CASE WHEN country_code = 'GB' THEN 'UK' ELSE country_code END) as country_code,
  Commission
from commission_tbl_af a
join `bi_export.lst_destination`  b
on a.user_country = b.country_name
group by 1,2,3
),

before as
(
SELECT
pos as Storefront,
SUM(hotel_impr) as Impressions_before,
SUM(clicks) as Clicks_before,
SUM(bookings) as Bookings_before,
SUM(gross_rev*fx_rate.currency_rate) as GBV_before,
SUM(cost*fx_rate.currency_rate) as Cost_before,
SAFE_DIVIDE(SUM(cost*fx_rate.currency_rate),SUM(bookings)) as CPA_Targets_before,
SUM(cost*fx_rate.currency_rate) + SUM(gross_rev*fx_rate.currency_rate)*0.03 as Total_Cost_before,
(SAFE_DIVIDE(SUM(clicks),SUM(hotel_impr))) as CTR_before,
(SAFE_DIVIDE(SUM(bookings),SUM(clicks))) as Conversion_before,
(SAFE_DIVIDE(SUM(beat * hotel_impr),SUM((1-unavailability)*hotel_impr))) as Percent_Beat_before,
-1*(SAFE_DIVIDE(SUM(1 - (unavailability * hotel_impr)),SUM(hotel_impr))) as Availability_before
FROM `metasearch_trivago_report_raw.hotel_report_*` as hotel_report
LEFT JOIN hqdatawarehouse.bi_export.fx_rate ON 1=1
AND fx_rate.date = hotel_report.date
AND prim_currency_code = 'EUR'
AND scnd_currency_code = 'USD'
WHERE 1=1
and _TABLE_SUFFIX >= '20161018'
[[ AND hotel_report.date >= {{ date_range_before_start }}]]
[[ AND hotel_report.date <= {{ date_range_before_end }}]]
GROUP BY 1
),

after as
(
SELECT
pos as Storefront,
SUM(hotel_impr) as Impressions_after,
SUM(clicks) as Clicks_after,
SUM(bookings) as Bookings_after,
SUM(gross_rev*fx_rate.currency_rate) as GBV_after,
SUM(cost*fx_rate.currency_rate) as Cost_after,
SAFE_DIVIDE(SUM(cost*fx_rate.currency_rate),SUM(bookings)) as CPA_Targets_after,
SUM(cost*fx_rate.currency_rate) + SUM(gross_rev*fx_rate.currency_rate)*0.03 as Total_Cost_after,
(SAFE_DIVIDE(SUM(clicks),SUM(hotel_impr))) as CTR_after,
(SAFE_DIVIDE(SUM(bookings),SUM(clicks))) as Conversion_after,
(SAFE_DIVIDE(SUM(beat * hotel_impr),SUM((1-unavailability)*hotel_impr))) as Percent_Beat_after,
-1*(SAFE_DIVIDE(SUM(1 - (unavailability * hotel_impr)),SUM(hotel_impr))) as Availability_after
FROM `metasearch_trivago_report_raw.hotel_report_*` as hotel_report
LEFT JOIN hqdatawarehouse.bi_export.fx_rate ON 1=1
AND fx_rate.date = hotel_report.date
AND prim_currency_code = 'EUR'
AND scnd_currency_code = 'USD'
WHERE 1=1
and _TABLE_SUFFIX >= '20161018'
[[ AND hotel_report.date >= {{ date_range_start }}]]
[[ AND hotel_report.date <= {{ date_range_end }}]]
GROUP BY 1
),

final_before as
(
select
Storefront,
Impressions_before,
Clicks_before,
Bookings_before,
GBV_before,
Cost_before,
CPA_Targets_before,
Commission - Total_Cost_before as PC3_before,
SAFE_DIVIDE((Commission - Total_Cost_before), GBV_before) as PC3_as_a_Percent_of_GBV_before,
CTR_before,
Conversion_before,
Percent_Beat_before,
Availability_before
from before b
left join country_code_bf c
on 1=1
and b.Storefront = c.country_code
order by GBV_before desc
),

final_after as
(
select
Storefront,
Impressions_after,
Clicks_after,
Bookings_after,
GBV_after,
Cost_after,
CPA_Targets_after,
Commission - Total_Cost_after as PC3_after,
SAFE_DIVIDE((Commission - Total_Cost_after), GBV_after) as PC3_as_a_Percent_of_GBV_after,
CTR_after,
Conversion_after,
Percent_Beat_after,
Availability_after
from after b
left join country_code_af c
on 1=1
and b.Storefront = c.country_code
order by GBV_after desc
)

SELECT
final_after.Storefront,
Impressions_before,
Impressions_after,
safe_divide((Impressions_after-Impressions_before), Impressions_before) as Impressions_change,
Clicks_before,
Clicks_after,
safe_divide((Clicks_after-Clicks_before), Clicks_before) as Clicks_change,
Bookings_before,
Bookings_after,
safe_divide((Bookings_after-Bookings_before), Bookings_before) as Bookings_change,
GBV_before,
GBV_after,
safe_divide((GBV_after-GBV_before), GBV_before) as GBV_change,
Cost_before,
Cost_after,
safe_divide((Cost_after-Cost_before), Cost_before) as Cost_change,
PC3_before,
PC3_after,
safe_divide((PC3_after-PC3_before), PC3_before) as PC3_change,
CTR_before,
CTR_after,
safe_divide((CTR_after-CTR_before), CTR_before) as CTR_change,
Conversion_before,
Conversion_after,
safe_divide((Conversion_after-Conversion_before), Conversion_before) as Conversion_change,
Percent_Beat_before,
Percent_Beat_after,
safe_divide((Percent_Beat_after-Percent_Beat_before), Percent_Beat_before) as Percent_Beat_change,
Availability_before,
Availability_after,
safe_divide((Availability_after-Availability_before), Availability_before) as Availability_change
FROM final_before
LEFT JOIN final_after on 1=1
AND final_before.Storefront = final_after.Storefront
ORDER BY GBV_after DESC
