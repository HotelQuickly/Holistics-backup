#standardSQL
select
date_trunc(DATE(m01_order_datetime_gmt0), DAY),
CASE
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <2 THEN '0 -1DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <16 THEN '2 -15DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <31 THEN '16 -30DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <91 THEN '30 -90DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <181 THEN '90 -180DIA'
	ELSE '180+ DIA' END,
sum(m07_selling_price_total_usd) as gbv
from
analyst.all_orders
where
date(m01_order_datetime_gmt0) >= {{ date_range_start }}
and date(m01_order_datetime_gmt0) <= {{ date_range_end }}
group by 1,2
order by 2
