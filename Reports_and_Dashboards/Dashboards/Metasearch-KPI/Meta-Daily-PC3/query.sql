#standardsql
SELECT
Date,
SUM(CASE WHEN Channel = 'trivago' THEN PC3 END) as trivago,
SUM(CASE WHEN Channel = 'tripadvisor' THEN PC3 END) as tripadvisor,
SUM(CASE WHEN Channel = 'hotelscombined' THEN PC3 END) as hotelscombined,
SUM(CASE WHEN Channel = 'skyscanner' THEN PC3 END) as skyscanner,
SUM(CASE WHEN Channel = 'kayak' THEN PC3 END) as kayak,
SUM(CASE WHEN Channel = 'hotellook' THEN PC3 END) as hotellook
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
[[ and date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
[[ and date(m01_order_datetime_gmt0) <=  {{ date_range_end }}  ]]
GROUP BY 1,2
)
SELECT
gbv_data.date1 as Date,
Channel1 as Channel,
CASE
  WHEN Channel1 = 'tripadvisor' THEN sum(commission)-sum(ta_cost)-sum(gbv*0.03)
  WHEN Channel1 = 'trivago' THEN sum(commission)-sum(trivago_cost)-sum(gbv*0.03)
  WHEN Channel1 = 'hotelscombined' THEN sum(commission)-sum(hotelscombined_cost)-sum(gbv*0.03)
  WHEN Channel1 = 'skyscanner' THEN sum(commission)-sum(gbv*0.12)-sum(gbv*0.03)
  WHEN Channel1 = 'kayak' THEN sum(commission)-sum(gbv*0.10)-sum(gbv*0.03)
  WHEN Channel1 = 'hotellook' THEN sum(commission)-sum(gbv*0.10)-sum(gbv*0.03) END
  as PC3
 FROM
gbv_data
  LEFT JOIN analyst.metasearch_cost ON 1=1
  AND metasearch_cost.date =  gbv_data.date1
WHERE 1=1
[[ and date1  >= {{ date_range_start }} ]]
[[ and date1 <=  {{ date_range_end }}  ]]
GROUP BY 1,2
ORDER BY 1 ASC
)
GROUP BY 1
ORDER BY 1 ASC
