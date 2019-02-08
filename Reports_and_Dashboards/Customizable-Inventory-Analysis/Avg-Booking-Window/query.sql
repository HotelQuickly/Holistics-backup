#standardsql
select
date(m01_order_datetime_gmt0) as order_date,
avg (date_diff (m138_offer_checkin_date, date(m01_order_datetime_gmt0), day)) as avg_booking_window
from
analyst.all_orders
where  1=1
and  [[ d22_inventory_source_code	in ({{ inventory_source }}) ]]
and  [[ DATE(m01_order_datetime_gmt0) >= ({{ date_range_start }}) ]]
and  [[ DATE(m01_order_datetime_gmt0) <=  ({{ date_range_end }})  ]]
and  [[ d08_order_status_name in ({{ order_status }}) ]]
and  [[ d12_hotel_country_name in ({{ hotel_country }}) ]]
and  [[ d10_hotel_city_name in ({{ hotel_city }}) ]]
and  [[ d58_user_base_country_name in ({{ user_base_country }}) ]]
and  [[ lower(d180_order_referral_source_code) in ({{channel }}) ]]
and  [[ d181_business_platform_code in ({{ platform }}) ]]
and  [[ cast(hotel_id as string) in ({{ hotel_id_test }}) ]]
and  [[ m138_offer_checkin_date >= ({{checkin_date_range_start}}) ]]
and  [[ m138_offer_checkin_date <= ({{checkin_date_range_end}}) ]]
group by 1
order by 1 asc
