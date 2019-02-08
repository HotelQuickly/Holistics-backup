#standardSQL
SELECT
DATE_TRUNC(m138_offer_checkin_date, {{ day_week_month|noquote }}) AS Date,
SUM(m07_selling_price_total_usd) as GBV,
COUNT(DISTINCT order_id) as Bookings
FROM
analyst.all_orders
where 1=1
and [[ date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
and [[ date(m01_order_datetime_gmt0) <= {{ date_range_end }} ]]
and [[ m138_offer_checkin_date >= {{ checkin_date_range_start }} ]]
and [[ m138_offer_checkin_date <= {{ checkin_date_range_end }} ]]
and [[ d08_order_status_name IN ({{ order_status }}) ]]
and [[ d58_user_base_country_name IN ({{ user_base_country }}) ]]
and [[ d22_inventory_source_code IN ({{ inventory_source }}) ]]
and [[ cast(hotel_id as string) IN ({{ hotel_id_test }}) ]]
and [[ d181_business_platform_code IN ({{ platform }}) ]]
and [[ lower(d180_order_referral_source_code) IN ({{ channel }}) ]]
and [[ d10_hotel_city_name IN ({{ hotel_city }}) ]]
and [[ d12_hotel_country_name IN ({{ hotel_country }}) ]]
and date_diff(current_date, m138_offer_checkin_date, day) <= 365
GROUP BY 1
ORDER BY 1
