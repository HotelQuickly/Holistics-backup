#standardSQL
WITH orders AS
(
SELECT
date(m01_order_datetime_gmt0) AS date,
sum (distinct CASE WHEN lower(d180_order_referral_source_code) = 'hotelscombined' THEN m07_selling_price_total_usd END ) AS hc_gbv,
sum (distinct CASE WHEN lower(d180_order_referral_source_code) = 'trivago' THEN m07_selling_price_total_usd END ) AS trivago_gbv,
sum (distinct CASE WHEN lower(d180_order_referral_source_code) = 'tripadvisor' THEN m07_selling_price_total_usd END ) AS ta_gbv,
sum (distinct CASE WHEN lower(d180_order_referral_source_code) = 'hqmobileapp' THEN m07_selling_price_total_usd END ) AS app_gbv,
sum (distinct CASE WHEN lower(d180_order_referral_source_code) = 'hqmobileapp' THEN vouchers_used_usd_amount_m74 END ) AS app_vouchers

FROM
analyst.all_orders
GROUP BY 1
)

SELECT
orders.date,
(trivago_cost / trivago_gbv) * 100 AS trivago,
(ta_cost / ta_gbv ) *100 AS tripadvisor,
(hotelscombined_cost / hc_gbv) * 100 AS hotelscombined
FROM
analyst.metasearch_cost
  LEFT JOIN orders ON 1=1
  AND orders.date = metasearch_cost.date
WHERE 1=1
[[ and orders.date >= {{ date_range_start }} ]]
[[ and orders.date <=  {{ date_range_end }}  ]]
ORDER BY 1 ASC
