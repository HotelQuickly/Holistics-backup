#standardSQL
WITH allorders_data AS
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
AND [[ date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
AND [[ date(m01_order_datetime_gmt0) <= {{ date_range_end }} ]]
GROUP BY 1
)
SELECT
Date1 as Date,
Bookings,
GBV,
ABV
FROM allorders_data
