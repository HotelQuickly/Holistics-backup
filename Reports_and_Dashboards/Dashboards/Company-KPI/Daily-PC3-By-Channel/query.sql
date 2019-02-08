#standardsql
SELECT
Date,
SUM(CASE WHEN Channel1 = 'tripadvisor' THEN PC3 END) as tripadvisor,
SUM(CASE WHEN Channel1 = 'trivago' THEN PC3 END) as trivago,
SUM(CASE WHEN Channel1 = 'hotelscombined' THEN PC3 END) as hotelscombined,
SUM(CASE WHEN Channel1 = 'skyscanner' THEN PC3 END) as skyscanner,
SUM(CASE WHEN Channel1 = 'kayak' THEN PC3 END) as kayak,
SUM(CASE WHEN Channel1 = 'hotellook' THEN PC3 END) as hotellook,
SUM(CASE WHEN Channel1 = 'hqmobileapp' THEN PC3 END) as hqmobileapp,
SUM(CASE WHEN Channel1 = 'hq-website' THEN PC3 END) as hq_website,
SUM(CASE WHEN Channel1 = 'direct-booking-via-hct' THEN PC3 END) as hct_direct,
SUM(CASE WHEN Channel1 = 'optimise-media-affiliate' THEN PC3 END) as optimisemedia,
SUM(CASE WHEN Channel1 = 'partnership' THEN PC3 END) as commissionfactory
FROM
(
WITH gbv_data AS
(
SELECT
date(m01_order_datetime_gmt0) as Date1,
lower(d180_order_referral_source_code) as Channel1,
IFNULL(SUM(m07_selling_price_total_usd),0) as GBV,
IFNULL(SUM(m12_amount_of_commission_earned_usd),0) as Commission,
IFNULL(SUM(vouchers_used_usd_amount_m74),0) as vouchers
FROM `analyst.all_orders`
WHERE 1=1
[[ and date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
[[ and date(m01_order_datetime_gmt0) <=  {{ date_range_end }}  ]]
GROUP BY 1,2
)
SELECT
gbv_data.date1 as Date,
Channel1,
CASE
  WHEN Channel1 = 'tripadvisor' THEN sum(commission)-sum(ta_cost)-sum(gbv*0.03)
  WHEN Channel1 = 'trivago' THEN sum(commission)-sum(trivago_cost)-sum(gbv*0.03)
  WHEN Channel1 = 'hotelscombined' THEN sum(commission)-sum(hotelscombined_cost)-sum(gbv*0.03)
  WHEN Channel1 = 'skyscanner' THEN sum(commission)-sum(gbv*0.15)
  WHEN Channel1 = 'kayak' THEN sum(commission)-sum(gbv*0.13)
  WHEN Channel1 = 'hotellook' THEN sum(commission)-sum(gbv*0.13)
  WHEN Channel1 = 'hqmobileapp' THEN sum(commission)-sum(vouchers) - sum(gbv*.03)
  WHEN Channel1 = 'hq-website' THEN sum(commission) - sum(gbv*.03)
  WHEN Channel1 = 'direct-booking-via-hct' THEN sum(commission)-sum(vouchers) - sum(gbv*.03)
  WHEN Channel1 = 'optimise-media-affiliate' THEN sum(commission) - sum(gbv*.11)
  WHEN Channel1 = 'partnership' THEN sum(commission) - sum(gbv*.10)
 END
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
