#standardsql
SELECT
CASE
WHEN nights = 1 THEN '1 Night'
WHEN nights = 2 THEN '2 Nights'
WHEN nights = 3 THEN '3 Nights'
WHEN nights = 4 THEN '4 Nights'
WHEN nights = 5 THEN '5 Nights'
WHEN nights = 6 THEn '6 Nights'
WHEN nights = 7 THEN '7 Nights'
ELSE '8 Or More Nights' END as Nights,
SUM(orders) as Bookings
FROM
(
select
m03_count_of_nights_booked as nights,
COUNT(distinct order_id) as orders
from
analyst.all_orders
where 1=1
and  [[ d22_inventory_source_code	in ({{ inventory_source }}) ]]
and  [[ DATE(m01_order_datetime_gmt0) >= ({{ date_range_start }}) ]]
and  [[ DATE(m01_order_datetime_gmt0) <=  ({{ date_range_end }})  ]]
and  [[ d08_order_status_name in ({{ order_status }}) ]]
and  [[ d12_hotel_country_name in ({{ hotel_country }}) ]]
and  [[ d10_hotel_city_name in ({{ hotel_city }}) ]]
and  [[ d58_user_base_country_name in ({{ user_base_country }}) ]]
and  [[ lower(d180_order_referral_source_code) in ({{ channel }}) ]]
and  [[ d181_business_platform_code in ({{ platform }})]]
and  [[ cast(hotel_id as string) in ({{ hotel_id_test }}) ]]
and  [[ m138_offer_checkin_date >= ({{ checkin_date_range_start }}) ]]
and  [[ m138_offer_checkin_date <=  ({{ checkin_date_range_end }})  ]]
group by 1
order by 1 asc
)
GROUP BY 1
ORDER BY 1
