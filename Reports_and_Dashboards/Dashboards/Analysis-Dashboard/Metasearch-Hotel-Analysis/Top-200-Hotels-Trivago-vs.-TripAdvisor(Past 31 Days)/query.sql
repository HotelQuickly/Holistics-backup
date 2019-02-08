#standardSQL
with top_hotels as
(
select
hotel_id as top_hotel_id,
d15_hotel_name as hotel_name,
sum(m07_selling_price_total_usd) as total_GBV,
rank() OVER (ORDER BY SUM(m07_selling_price_total_usd) DESC) as gbv_rank
from
analyst.all_orders
WHERE 1=1
and [[ date(m01_order_datetime_gmt0 ) >= {{date_range_start}} ]]
and [[ date(m01_order_datetime_gmt0 ) <= {{date_range_end}} ]]
--date_diff(current_date, date(m01_order_datetime_gmt0), day) <= 31
--AND lower(d180_order_referral_source_code) IN ('trivago','tripadvisor')
group by 1,2
limit 200
)
,
trivago as
(
WITH all_orders_data AS
(
SELECT
hotel_id,
IFNULL(COUNT(DISTINCT order_id),0) as all_orders_Bookings,
SUM(m07_selling_price_total_usd) as all_orders_GBV,
SUM(m12_amount_of_commission_earned_usd) as all_orders_Commission
FROM `analyst.all_orders`
WHERE 1=1
AND lower(d180_order_referral_source_code) IN ('trivago')
and [[ date(m01_order_datetime_gmt0 ) >= {{date_range_start}} ]]
and [[ date(m01_order_datetime_gmt0 ) <= {{date_range_end}} ]]

--date_diff(current_date, date(m01_order_datetime_gmt0), day) <= 31
GROUP BY 1
),
hotel_report_data AS
(
SELECT
partner_ref,
AVG(bid_cpc*fx_rate.currency_rate) as trivago_Bid,
SUM(hotel_impr) as hr_Impressions,
SUM(clicks) as hr_Clicks,
SUM(bookings) as hr_Bookings,
SUM(gross_rev*fx_rate.currency_rate) as hr_GBV,
SUM(cost*fx_rate.currency_rate) as hr_Cost,
(SUM(gross_rev*fx_rate.currency_rate)*0.108 - SUM(cost*fx_rate.currency_rate) - SUM(gross_rev*fx_rate.currency_rate)*0.03) as hr_Estimated_PC3,
(SAFE_DIVIDE(SUM(clicks),SUM(hotel_impr))) as hr_CTR,
(SAFE_DIVIDE(SUM(bookings),SUM(clicks))) as hr_Conversion,
(SAFE_DIVIDE(SUM(beat * hotel_impr),SUM((1-unavailability)*hotel_impr))) as hr_Percent_Beat,
-1*(SAFE_DIVIDE(SUM(1 - (unavailability * hotel_impr)),SUM(hotel_impr))) as hr_Availability
FROM `metasearch_trivago_report_raw.hotel_report_*` as hotel_report
LEFT JOIN hqdatawarehouse.bi_export.fx_rate ON 1=1
AND fx_rate.date = hotel_report.date
AND prim_currency_code = 'EUR'
AND scnd_currency_code = 'USD'
WHERE 1=1
and _TABLE_SUFFIX >= '20180101'
and [[ hotel_report.date >= {{date_range_start}} ]]
and [[ hotel_report.date <= {{date_range_end}} ]]

--date_diff(current_date,hotel_report.date, day) <= 31

GROUP BY 1
ORDER BY 1 DESC
)
SELECT
hotel_id as triv_hotel_id,
partner_ref,
trivago_Bid,
all_orders_GBV,
hr_GBV,
all_orders_Commission,
all_orders_Bookings,
hr_Bookings,
hr_Clicks,
SAFE_DIVIDE(all_orders_Bookings,hr_Clicks) as all_orders_Conversion,
hr_Conversion,
hr_Cost,
all_orders_Commission - hr_Cost - all_orders_GBV*0.03 as all_orders_PC3,
hr_Estimated_PC3,
hr_Percent_Beat,
hr_Availability
 FROM
all_orders_data
  LEFT JOIN hotel_report_data ON 1=1
  AND CAST (hotel_id AS STRING) = partner_ref
),
tripadvisor as
(
WIth trip_bookings AS
(
SELECT
hotel_id,
SUM(m07_selling_price_total_usd) as GBV,
SUM(m12_amount_of_commission_earned_usd) as Commission,
COUNT(distinct order_id) as Bookings,
SAFE_DIVIDE(SUM(m07_selling_price_total_usd),COUNT(distinct order_id)) as ABV,
COUNT(DISTINCT CASE WHEN d08_order_status_name = 'Active' THEN order_id END) as Active_Bookings
FROM analyst.all_orders
WHERE 1=1
and [[ date(m01_order_datetime_gmt0 ) >= {{date_range_start}} ]]
and [[ date(m01_order_datetime_gmt0 ) <= {{date_range_end}} ]]
--date_diff(current_date, date(m01_order_datetime_gmt0), day) <= 31
AND lower(d180_order_referral_source_code) = 'tripadvisor'
GROUP By 1
),
trip_clicks as
(
Select
location_id,
sum(cost_in_USD)/SUM(clicks) as avg_TA_bid,
sum(cost_in_USD) as Cost,
SUM(clicks) as Clicks
FROM `metasearch_tripadvisor_report_raw.click_cost_*`
WHERE 1=1
and [[ report_date >= {{date_range_start}} ]]
and [[ report_date <= {{date_range_end}} ]]


--date_diff(current_date, report_date, day) <= 31
GROUP BY 1
)
SELECT
hotel_id as ta_hotel_id,
avg_TA_bid,
GBV as TA_GBV,
Bookings as TA_Bookings,
SAFE_DIVIDE((Bookings-Active_Bookings),(Bookings)) as Cancellation_Rate,
ABV,
Cost as Cost,
Clicks,
SAFE_DIVIDE(Bookings,Clicks) as TA_Conversion,
Commission - Cost - GBV*0.03 as PC3
FROM trip_bookings
LEFT JOIN trip_clicks ON 1=1
AND hotel_id = location_id
ORDER BY 3 DESC
)
select
gbv_rank as Rank,
top_hotel_id as Hotel_ID,
hotel_name as Hotel_Name,
TA_GBV/total_GBV as Tripadvisor_GBV,
all_orders_GBV/total_GBV as Trivago_GBV,
--1-(TA_GBV/total_GBV)-(all_orders_GBV/total_GBV) as Other_GBV,
Total_GBV,
TA_Bookings,
all_orders_Bookings as Trivago_Bookings,
avg_TA_bid as Avg_TA_Bid,
trivago_Bid as Avg_Trivago_Bid
from
top_hotels
LEFT join
tripadvisor on 1=1
and top_hotel_id = ta_hotel_id
LEFT JOIN
trivago on 1=1
and top_hotel_id = triv_hotel_id
ORDER BY 1 ASC
