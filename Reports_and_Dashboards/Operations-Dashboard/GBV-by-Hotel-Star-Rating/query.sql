#standardSQL
with hotel_gbv as
(
SELECT
  a.*,
  d37_hotel_category_name star_rating
FROM
analyst.all_orders a
left join bi_export.hotel b
on 1=1
and a.hotel_id = b.hotel_id
where 1=1
and [[ date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
and [[ date(m01_order_datetime_gmt0) <= {{ date_range_end }} ]]
and [[ m138_offer_checkin_date >= {{ checkin_date_range_start }} ]]
and [[ m138_offer_checkin_date <= {{ checkin_date_range_end }} ]]
and [[ d08_order_status_name IN({{ order_status }}) ]]
and [[ a.d12_hotel_country_name in ({{ hotel_country }}) ]]
and [[ a.d10_hotel_city_name in ({{ hotel_city }}) ]]
and [[ d58_user_base_country_name in ({{ user_base_country }}) ]]
and [[ lower(d180_order_referral_source_code) in ({{ channel }}) ]]
and [[ d181_business_platform_code in ( {{ platform }} ) ]]
and [[ d22_inventory_source_code in ( {{ inventory_source }} ) ]]
and [[ contracted_hotel_indicator in ( {{contracted_hotel_indicator }} ) ]]
order by 1 desc
)

select
  Star_Rating,
  count(distinct order_id) Bookings,
  sum(m03_count_of_nights_booked) as RNS,
  round(sum(m07_selling_price_total_usd),0) GBV
from hotel_gbv
group by 1
order by 1 desc
