#standardSQL
SELECT
all_orders.hotel_id as Hotel_ID,
all_orders.d10_hotel_city_name as City,
all_orders.d15_hotel_name as Hotel_Name,
contracted_hotel_indicator as Contracted_Indicator,
count(distinct order_id) AS Orders,
sum(m03_count_of_nights_booked) AS RNS,
round(sum(m07_selling_price_total_usd),0) AS GBV
FROM
analyst.all_orders
left join bi_export.hotel
on 1=1
and all_orders.hotel_id = hotel.hotel_id
where 1=1
and [[ date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
and [[ date(m01_order_datetime_gmt0) <= {{ date_range_end }} ]]
and [[ m138_offer_checkin_date >= {{ checkin_date_range_start }} ]]
and [[ m138_offer_checkin_date <= {{ checkin_date_range_end }} ]]
and [[ d08_order_status_name IN({{ order_status }}) ]]
and [[ all_orders.d12_hotel_country_name in ({{ hotel_country }}) ]]
and [[ all_orders.d10_hotel_city_name in ({{ hotel_city }}) ]]
and [[ d58_user_base_country_name in ({{ user_base_country }}) ]]
and [[ lower(d180_order_referral_source_code) in ({{ channel }}) ]]
and [[ d181_business_platform_code in ( {{ platform }} ) ]]
and [[ d22_inventory_source_code in ( {{ inventory_source }} ) ]]
and [[ contracted_hotel_indicator in ( {{contracted_hotel_indicator }} ) ]]
group by 1,2,3,4
--having count(distinct order_id) > 2
order by 6 desc
