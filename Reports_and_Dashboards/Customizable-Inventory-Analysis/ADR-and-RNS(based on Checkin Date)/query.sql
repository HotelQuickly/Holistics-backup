#standardsql
select
date_trunc(m138_offer_checkin_date, {{ day_week_month|noquote }}) as order_date,
ROUND(SAFE_DIVIDE(sum(m07_selling_price_total_usd),sum(m03_count_of_nights_booked)),0) as Average_Daily_Rate,
sum(m03_count_of_nights_booked) as Total_Nights_Booked
from analyst.all_orders
where  1=1
and  [[ d22_inventory_source_code	in ({{ inventory_source }}) ]]
and  [[ DATE(m01_order_datetime_gmt0) >= ({{ date_range_start }}) ]]
and  [[ DATE(m01_order_datetime_gmt0) <=  ({{ date_range_end }})  ]]
and  [[ d08_order_status_name in ({{ order_status }}) ]]
and  [[ d12_hotel_country_name in ({{ hotel_country }}) ]]
and  [[ d10_hotel_city_name in ({{ hotel_city }}) ]]
and  [[ d58_user_base_country_name in ({{ user_base_country }}) ]]
and  [[ lower(d180_order_referral_source_code) in ({{ channel }}) ]]
and  [[ d181_business_platform_code in ( {{ platform }} ) ]]
and  [[ cast(hotel_id as string) in ({{ hotel_id_test }}) ]]
and  [[ m138_offer_checkin_date >= ({{checkin_date_range_start}}) ]]
and  [[ m138_offer_checkin_date <= ({{checkin_date_range_end}}) ]]
and date_diff(current_date, m138_offer_checkin_date, day) <= 365
group by 1
order by 1 asc
