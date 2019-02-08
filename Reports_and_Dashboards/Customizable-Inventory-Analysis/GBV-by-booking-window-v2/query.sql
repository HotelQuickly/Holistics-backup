#standardsql
SELECT
order_week,
booking_window,
(gbv / week_total) * 100 as percent_of_total
FROM
(
SELECT
order_week,
booking_window,
gbv,
sum(gbv) over (partition by order_week) AS week_total
FROM
(
select
date_trunc(date(m01_order_datetime_gmt0),week) as order_week,
case when (date_diff (m138_offer_checkin_date, date(m01_order_datetime_gmt0), day)) <3 then 'a) 0 - 2'
     when (date_diff (m138_offer_checkin_date, date(m01_order_datetime_gmt0), day)) >= 3 and (date_diff (m138_offer_checkin_date, date(m01_order_datetime_gmt0), day)) <= 7 then 'b) 3 - 7'
     when (date_diff (m138_offer_checkin_date, date(m01_order_datetime_gmt0), day)) >7 and (date_diff (m138_offer_checkin_date, date(m01_order_datetime_gmt0), day)) <= 15 then 'c) 8 - 15'
     when (date_diff (m138_offer_checkin_date, date(m01_order_datetime_gmt0), day)) >15 and (date_diff (m138_offer_checkin_date, date(m01_order_datetime_gmt0), day)) <= 30 then 'd) 16 - 30'
     when (date_diff (m138_offer_checkin_date, date(m01_order_datetime_gmt0), day)) > 30 and (date_diff (m138_offer_checkin_date, date(m01_order_datetime_gmt0), day)) <= 45 then 'e) 31 - 45'
     when (date_diff (m138_offer_checkin_date, date(m01_order_datetime_gmt0), day)) > 45 and (date_diff (m138_offer_checkin_date, date(m01_order_datetime_gmt0), day)) <= 90 then 'f) 46 - 90'
     when (date_diff (m138_offer_checkin_date, date(m01_order_datetime_gmt0), day)) > 90 then 'g) > 90' end as booking_window,
sum(m07_selling_price_total_usd) as GBV
from analyst.all_orders
where date_diff(current_date, date(m01_order_datetime_gmt0), day) <= 365
and  [[ d22_inventory_source_code	in ({{ inventory_source }}) ]]
and  [[ d08_order_status_name in ({{ order_status }}) ]]
and  [[ d12_hotel_country_name in ({{ hotel_country }}) ]]
and  [[ d10_hotel_city_name in ({{ hotel_city }}) ]]
and  [[ d58_user_base_country_name in ({{ user_base_country }}) ]]
and  [[ lower(d180_order_referral_source_code) in ({{ channel }}) ]]
and  [[ d181_business_platform_code in ( {{ platform }} ) ]]
and  [[ cast(hotel_id as string) in ({{ hotel_id_test }}) ]]
and  [[ m138_offer_checkin_date >= ({{checkin_date_range_start}}) ]]
and  [[ m138_offer_checkin_date <= ({{checkin_date_range_end}}) ]]
group by 1,2
order by 1,2 DESC
)
group by 1,2,3
)
group by 1,2,3
order by 1,2
