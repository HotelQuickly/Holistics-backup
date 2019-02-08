#standardSQL
SELECT
*
FROM
(SELECT
*
FROM
(

(WIth trip_bookings AS
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
and date_diff(current_date, date(m01_order_datetime_gmt0), day) <= 31
AND lower(d180_order_referral_source_code) = 'tripadvisor'
GROUP By 1
),
trip_clicks as
(
Select
location_id,
sum(cost_in_USD) as Cost,
SUM(clicks) as Clicks,
ROUND((sum(cost_in_USD)/100)/SUM(clicks),3) as Avg_bid
FROM `metasearch_tripadvisor_report_raw.click_cost_*` as click_cost
WHERE 1=1
AND date_diff(current_date, click_cost.report_date , day) <= 31


GROUP BY 1
)
SELECT
--trip_bookings.hotel_id as all_orders_hotel_id,
location_id as hotel_id,
d15_hotel_name as hotel_name,
GBV,
Bookings,
IFNULL(Commission,0) - Cost - IFNULL(GBV*0.03,0) as PC3,
--SAFE_DIVIDE((Bookings-Active_Bookings),(Bookings)) as Cancellation_Rate,
--ABV,
Cost,
Clicks,
--Avg_bid,
SAFE_DIVIDE(Bookings,Clicks) as Conversion
--IFNULL(Commission,0) - Cost as Margin,
FROM trip_bookings
FULL OUTER JOIN trip_clicks ON 1=1
AND hotel_id = location_id
LEFT JOIN `bi_export.hotel` as hotel_table ON 1=1
AND location_id = hotel_table.hotel_id
ORDER BY clicks DESC
)


)
WHERE hotel_id IS NOT NULL
)
WHERE 1=1
AND PC3 > 0
ORDER BY PC3 DESC
LIMIT 100
