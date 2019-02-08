#standardsql
select
  CASE
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <2 THEN 'A. 0-1DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <4 THEN 'B. 2-3DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <6 THEN 'C. 4-5DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <8 THEN 'D. 6-7DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <16 THEN 'E. 8-15DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <31 THEN 'F. 16-30DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <46 THEN 'G. 31-45DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <61 THEN 'H. 46-60DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <91 THEN 'I. 61-90DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <181 THEN 'J. 91-180DIA'
	ELSE 'K. 180+ DIA' END AS booking_window,
sum(m07_selling_price_total_usd) AS gbv
from analyst.all_orders
where d181_business_platform_code = 'app'
and  [[ DATE(m01_order_datetime_gmt0) >= ({{ date_range_start }}) ]]
and  [[ DATE(m01_order_datetime_gmt0) <=  ({{ date_range_end }})  ]]
group by 1
order by 1
