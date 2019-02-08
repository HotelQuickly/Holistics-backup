#standardSQL
WITH sky_data AS
(
SELECT
DATE_TRUNC(date(m01_order_datetime_gmt0), {{ day_week_month|noquote }}) AS Date1,
COUNT(DISTINCT order_id) as Bookings,
ROUND(SUM(m07_selling_price_total_usd),0) as GBV,
ROUND(SUM(m07_selling_price_total_usd)/COUNT(DISTINCT order_id),0) as ABV,
ROUND(SUM(m12_amount_of_commission_earned_usd),0) as Commission,
ROUND(SAFE_DIVIDE(SUM(m12_amount_of_commission_earned_usd),SUM(m07_selling_price_total_usd)),4) as Commission_Percent,
ROUND(SUM(m07_selling_price_total_usd)*(SAFE_DIVIDE(SUM(m12_amount_of_commission_earned_usd),SUM(m07_selling_price_total_usd)-SUM(m12_amount_of_commission_earned_usd))),0) as Markup_Amount,
ROUND(SAFE_DIVIDE(SUM(m12_amount_of_commission_earned_usd),SUM(m07_selling_price_total_usd)-SUM(m12_amount_of_commission_earned_usd)),4) as Markup_Percent
FROM analyst.all_orders
WHERE 1=1
AND lower(d180_order_referral_source_code) = 'skyscanner'
AND [[ date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
AND [[ date(m01_order_datetime_gmt0) <= {{ date_range_end }} ]]
GROUP BY 1
),
sky_clicks AS(
SELECT
DATE_TRUNC(date(time), {{ day_week_month|noquote }}) AS Date2,
COUNT(*) as Requests,
COUNT(DISTINCT session_id) as Sessions
FROM metasearch.log_availability
WHERE 1=1
AND consumer_code ='skyscanner'
AND [[ date(time) >= {{ date_range_start }} ]]
AND [[ date(time) <= {{ date_range_end }} ]]
GROUP BY 1
),
sky_cost AS
(
SELECT
DATE_TRUNC(date, {{ day_week_month|noquote }}) AS Date3,
SUM(skyscanner_cost) as Cost
FROM analyst.metasearch_cost
WHERE 1=1
AND [[ date >= {{ date_range_start }} ]]
AND [[ date <= {{ date_range_end }} ]]
GROUP BY 1
)
SELECT
Date1 as Date,
Requests,
Sessions,
Bookings,
ROUND(Bookings/Sessions,4) as Conversion_Percent,
GBV,
ABV,
Commission,
Commission_Percent,
Markup_Amount,
Markup_Percent,
ROUND(sky_cost.cost,0) as Cost,
ROUND((Commission-GBV*0.03),0) as Margin,
ROUND((Commission-sky_cost.Cost-GBV*0.03),0) as PC3
FROM sky_data
LEFT JOIN sky_clicks ON 1=1
AND sky_data.Date1 = sky_clicks.Date2
LEFT JOIN sky_cost ON 1=1
AND sky_data.Date1 = sky_cost.Date3
ORDER BY 1 DESC
