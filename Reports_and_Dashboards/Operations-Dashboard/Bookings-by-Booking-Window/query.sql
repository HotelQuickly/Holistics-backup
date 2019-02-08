#standardSQL
SELECT
CASE
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <2 THEN '1) 0 -1DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <8 THEN '2) 2 -7DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <15 THEN '3) 8 -14DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <31 THEN '4) 15 -30DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <91 THEN '5) 30 -90DIA'
	WHEN DATE_DIFF(m138_offer_checkin_date,date(m01_order_datetime_gmt0),DAY) <181 THEN '6) 90 -180DIA'
	ELSE '7) 180+ DIA' END AS booking_window,
count(distinct order_id) AS bookings
FROM
analyst.all_orders
where 1=1
and [[ date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
and [[ date(m01_order_datetime_gmt0) <= {{ date_range_end }} ]]
and [[ m138_offer_checkin_date >= {{ checkin_date_range_start }} ]]
and [[ m138_offer_checkin_date <= {{ checkin_date_range_end }} ]]
and [[ d08_order_status_name IN({{ order_status }}) ]]
and [[ d12_hotel_country_name in ({{ hotel_country }}) ]]
and [[ d10_hotel_city_name in ({{ hotel_city }}) ]]
and [[ d58_user_base_country_name in ({{ user_base_country }}) ]]
and [[ lower(d180_order_referral_source_code) in ({{ channel }}) ]]
and [[ d181_business_platform_code in ( {{ platform }} ) ]]
and [[ lower(d22_inventory_source_code) in ( {{ inventory_source }} ) ]]
group by 1
order by 1,2 desc
