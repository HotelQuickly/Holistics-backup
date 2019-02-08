#standardSQL
SELECT
DATE(m01_order_datetime_gmt0) as Date,
order_id,
hotel_id,
m07_selling_price_total_usd as GBV,
m12_amount_of_commission_earned_usd as Commission,
m12_amount_of_commission_earned_usd/m07_selling_price_total_usd as Commission_Percent_of_GBV,
--m07_selling_price_total_usd - m208_source_price_usd as commission_2,
d22_inventory_source_code as Inventory_Source,
d180_order_referral_source_code as Channel
FROm `analyst.all_orders`
WHERE 1=1
AND d180_order_referral_source_code = 'GOOGLE-ADWORDS-SEARCH'
and [[ date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
and [[ date(m01_order_datetime_gmt0) <= {{ date_range_end }} ]]
ORDER BY 1 DESC
