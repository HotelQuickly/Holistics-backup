#standardSQL

SELECT *
FROM
(WITH all_orders_data AS
(
SELECT
hotel_id,
d15_hotel_name,
IFNULL(COUNT(DISTINCT order_id),0) as all_orders_Bookings,
SUM(m07_selling_price_total_usd) as all_orders_GBV,
SUM(m12_amount_of_commission_earned_usd) as all_orders_Commission
FROM `analyst.all_orders`
WHERE 1=1
AND lower(d180_order_referral_source_code) IN ('trivago')
and date_diff(current_date, date(m01_order_datetime_gmt0), day) <= 31
GROUP BY 1,2
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
and _TABLE_SUFFIX >= '20170101'
and date_diff(current_date,hotel_report.date, day) <= 31
GROUP BY 1
ORDER BY 1 DESC
)
SELECT
hotel_table.hotel_id,
--partner_ref,
hotel_table.d15_hotel_name as hotel_name,
IFNULL(all_orders_GBV,0) as GBV,
--hr_GBV,
--all_orders_Commission as Commission,
IFNULL(all_orders_Bookings,0) as Bookings,
IFNULL(all_orders_Commission,0)- IFNULL(hr_Cost,0) - IFNULL(all_orders_GBV*0.03,0) as PC3,
--hr_Bookings,
hr_Clicks as Clicks,
hr_Cost as Cost,
SAFE_DIVIDE(all_orders_Bookings,hr_Clicks) as Conversion,
--hr_Conversion,
hr_Percent_Beat as Percent_Beat,
hr_Availability as Availability
 FROM
hotel_report_data
  FULL OUTER JOIN all_orders_data ON 1=1
  AND CAST (hotel_id AS STRING) = partner_ref
  LEFT JOIN `bi_export.hotel` as hotel_table ON 1=1
  AND partner_ref = CAST (hotel_table.hotel_id as STRING)


)
WHERE PC3 < 0
ORDER BY PC3 ASC
LIMIT 100
