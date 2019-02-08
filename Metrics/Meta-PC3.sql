-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

#standardsql
SELECT
round(SUM(PC3), 0)
FROM
(
WITH gbv_data AS
(
SELECT
date(m01_order_datetime_gmt0) as Date1,
lower(d180_order_referral_source_code) as Channel1,
IFNULL(SUM(m07_selling_price_total_usd),0) as GBV,
IFNULL(SUM(m12_amount_of_commission_earned_usd),0) as Commission
FROM `analyst.all_orders`
WHERE 1=1
AND {{ @Include_Relevant_Meta }}
GROUP BY 1,2
)
SELECT
gbv_data.date1 as Date,
Channel1 as Channel,
CASE
  WHEN Channel1 = 'tripadvisor' THEN sum(commission)-sum(ta_cost)-sum(gbv*0.03)
  WHEN Channel1 = 'trivago' THEN sum(commission)-sum(trivago_cost)-sum(gbv*0.03)
  WHEN Channel1 = 'hotelscombined' THEN sum(commission)-sum(hotelscombined_cost)-sum(gbv*0.03)
  WHEN Channel1 = 'skyscanner' THEN sum(commission)-sum(gbv*0.15)
  WHEN Channel1 = 'kayak' THEN sum(commission)-sum(gbv*0.13)
  WHEN Channel1 = 'hotellook' THEN sum(commission)-sum(gbv*0.13) END
  as PC3
 FROM
gbv_data
  LEFT JOIN analyst.metasearch_cost ON 1=1
  AND metasearch_cost.date =  gbv_data.date1
GROUP BY 1,2
ORDER BY 1 DESC
)
WHERE {{time_where}}
