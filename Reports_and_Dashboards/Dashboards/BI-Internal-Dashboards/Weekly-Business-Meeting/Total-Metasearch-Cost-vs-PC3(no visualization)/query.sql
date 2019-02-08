#standardSQL
with cst as
(
SELECT
date,
trivago_cost +
ta_cost +
hotelscombined_cost +
skyscanner_cost +
kayak_cost +
hotellook_cost as cost
FROM
analyst.metasearch_cost
WHERE 1=1
[[ and date >= {{ date_range_start }} ]]
[[ and date <=  {{ date_range_end }}  ]]
ORDER BY 1 ASC
)
,
profit as
(
SELECT
DATE_TRUNC(Date, {{ day_week_month|noquote }}) AS Date,
ROUND(SUM(PC3),0) as PC3
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
ORDER BY 1 DESC
)
GROUP BY 1
)
select
cst.date,
cost,
pc3
from
cst
left join profit
on 1=1
and cst.date =  profit.Date
