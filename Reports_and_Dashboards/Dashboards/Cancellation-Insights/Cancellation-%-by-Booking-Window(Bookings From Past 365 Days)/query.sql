#standardsql
select
booking_window,
(gbv/range_total) as percent_of_total_gbv_in_range
from
(
select
booking_window,
d08_order_status_name,
gbv,
sum(gbv) over (partition by booking_window) as range_total
from
(
select
CASE
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <2 THEN '1) 0 -1DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <8 THEN '2) 2 -7DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <15 THEN '3) 8 -14DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <31 THEN '4) 15 -30DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <91 THEN '5) 30 -90DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <181 THEN '6) 90 -180DIA'
	ELSE '7) 180+ DIA' END AS booking_window,
d08_order_status_name,
sum(m07_selling_price_total_usd) as gbv
from
analyst.all_orders
where 1=1
and date_diff(current_date, date(m01_order_datetime_gmt0),DAY) <= 365
group by 1,2
)
)
where
d08_order_status_name = 'Cancelled'
