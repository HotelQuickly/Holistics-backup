#standardsql
select
  CASE
	WHEN DATE_DIFF(date(d77_user_first_booking_datetime_gmt0),date(d111_first_device_install_datetime_gmt0),DAY) <2 THEN 'A. 0-1D'
	WHEN DATE_DIFF(date(d77_user_first_booking_datetime_gmt0),date(d111_first_device_install_datetime_gmt0),DAY) <4 THEN 'B. 2-3D'
	WHEN DATE_DIFF(date(d77_user_first_booking_datetime_gmt0),date(d111_first_device_install_datetime_gmt0),DAY) <6 THEN 'C. 4 -5D'
	WHEN DATE_DIFF(date(d77_user_first_booking_datetime_gmt0),date(d111_first_device_install_datetime_gmt0),DAY) <8 THEN 'D. 6 -7D'
	WHEN DATE_DIFF(date(d77_user_first_booking_datetime_gmt0),date(d111_first_device_install_datetime_gmt0),DAY) <16 THEN 'E. 8 -15D'
	WHEN DATE_DIFF(date(d77_user_first_booking_datetime_gmt0),date(d111_first_device_install_datetime_gmt0),DAY) <31 THEN 'F. 16 -30D'
	WHEN DATE_DIFF(date(d77_user_first_booking_datetime_gmt0),date(d111_first_device_install_datetime_gmt0),DAY) <46 THEN 'G. 31 -45D'
	WHEN DATE_DIFF(date(d77_user_first_booking_datetime_gmt0),date(d111_first_device_install_datetime_gmt0),DAY) <61 THEN 'H. 46 -60D'
	WHEN DATE_DIFF(date(d77_user_first_booking_datetime_gmt0),date(d111_first_device_install_datetime_gmt0),DAY) <91 THEN 'I. 61 -90D'
	WHEN DATE_DIFF(date(d77_user_first_booking_datetime_gmt0),date(d111_first_device_install_datetime_gmt0),DAY) <181 THEN 'J. 91 -180D'
	ELSE 'X. 180+D' END AS install_to_order,
  sum(m07_selling_price_total_usd) AS gbv,
  count(distinct order_id) as bookings
from analyst.all_orders
where d181_business_platform_code = 'app'
[[ and date(d111_first_device_install_datetime_gmt0) >= {{ date_range_start }} ]]
[[ and date(d111_first_device_install_datetime_gmt0) <= {{ date_range_end }} ]]
and date(d111_first_device_install_datetime_gmt0) = date(d33_device_install_datetime_gmt0)
and date(d77_user_first_booking_datetime_gmt0) = date(m01_order_datetime_gmt0)
group by 1
order by 1
