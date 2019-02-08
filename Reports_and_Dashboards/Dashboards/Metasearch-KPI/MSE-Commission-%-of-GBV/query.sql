#standardSQL
select
date_trunc(DATE(m01_order_datetime_gmt0), DAY),

100*(sum(CASE WHEN lower(d180_order_referral_source_code) = 'trivago' THEN m12_amount_of_commission_earned_usd END)
/
SUM(CASE WHEN lower(d180_order_referral_source_code) = 'trivago' THEN m07_selling_price_total_usd END))
AS trivago,
100*(sum(CASE WHEN lower(d180_order_referral_source_code) = 'tripadvisor' THEN m12_amount_of_commission_earned_usd END)
/
SUM(CASE WHEN lower(d180_order_referral_source_code) = 'tripadvisor' THEN m07_selling_price_total_usd END))
AS tripadvisor,
100*(sum(CASE WHEN lower(d180_order_referral_source_code) = 'hotelscombined' THEN m12_amount_of_commission_earned_usd END)
/
SUM(CASE WHEN lower(d180_order_referral_source_code) = 'hotelscombined' THEN m07_selling_price_total_usd END))
AS hotelscombined
FROM
analyst.all_orders
where
[[ date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]

[[ and date(m01_order_datetime_gmt0) <=  {{ date_range_end }}  ]]

group by 1
ORDER BY 1 ASC
