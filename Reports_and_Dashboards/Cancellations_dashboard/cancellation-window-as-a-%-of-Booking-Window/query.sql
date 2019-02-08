#standardsql
select
booking_window,
cancellation_window_percent,
(bookings/range_total) as percent_of_total
from
(
select
booking_window,
cancellation_window_percent,
bookings,
sum(bookings) over (partition by booking_window) as range_total
from
(
select
CASE
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <15 THEN '1) 0 -15DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <30 THEN '2) 15 -30DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <60 THEN '3) 30 -60DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <90 THEN '4) 60 -90DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <181 THEN '5) 90 -180DIA'
	ELSE '6) 180+ DIA' END AS booking_window,
case
  when date_diff(date(m171_order_cancelled_datetime_gmt0), date(m01_order_datetime_gmt0 ), day) < 0.2*date_diff(m138_offer_checkin_date , date(m01_order_datetime_gmt0 ), day) then 'Cancelled within 0-20% of Booking Window'
  when date_diff(date(m171_order_cancelled_datetime_gmt0), date(m01_order_datetime_gmt0 ), day) < 0.4*date_diff(m138_offer_checkin_date , date(m01_order_datetime_gmt0 ), day) then 'Cancelled within 20-40% of Booking Window'
  when date_diff(date(m171_order_cancelled_datetime_gmt0), date(m01_order_datetime_gmt0 ), day) < 0.6*date_diff(m138_offer_checkin_date , date(m01_order_datetime_gmt0 ),day) then 'Cancelled within 40-60% of Booking Window'
  when date_diff(date(m171_order_cancelled_datetime_gmt0), date(m01_order_datetime_gmt0 ), day) < 0.8*date_diff(m138_offer_checkin_date , date(m01_order_datetime_gmt0 ), day) then 'Cancelled within 60-80% of Booking Window'
  else 'Cancelled within 80-100% of Booking Window' end as cancellation_window_percent,
count(distinct order_id) as bookings
from
`analyst.all_orders`
where 1=1
and d08_order_status_name = 'Cancelled'
and date_diff(current_date, date(m01_order_datetime_gmt0), day) <= 365
group by 1,2
order by 1,2
)
)
order by 1,2
