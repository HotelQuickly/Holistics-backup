#standardsql
with allorders_ranked as
(
select
  a.user_id,
  a.d13_user_full_name user_name,
  b.d58_user_base_country_name user_first_booked_country,
  order_id,
  date(m01_order_datetime_gmt0) booking_date,
  d08_order_status_name status,
  a.d58_user_base_country_name user_country,
  d15_hotel_name hotel,
  d10_hotel_city_name hotel_city,
  d12_hotel_country_name hotel_country,
  m07_selling_price_total_usd gbv,
  vouchers_used_usd_amount_m74 vouchers,
  date_diff(m138_offer_checkin_date, date(m01_order_datetime_gmt0), day) as days_in_advance,
  rank() over(partition by a.user_id order by m01_order_datetime_gmt0) as r
from `analyst.all_orders` a
join `bi_export.user` b
on a.user_id = b.user_id
where a.d181_business_platform_code = 'app'
order by user_id, r
),
allorders_app as
(
select
  b.*
from allorders_ranked a, allorders_ranked b
where 1=1
and a.user_id = b.user_id
and a.r = 1
and b.r >= 1
and a.booking_date >= '2017-01-01'
order by 1,5,b.r
)
select
  user_id,
  --user_name,
  user_first_booked_country as user_country,
  round(avg(days_in_advance), 2) as avg_days_in_advance,
  count(distinct order_id) bookings,
  count(distinct hotel) as hotels_booked,
  round(sum(gbv),2) gbv,
  round(sum(vouchers),2) vouchers_used,
  sum(vouchers)/sum(gbv) perc_vouchers_used,
  sum(case when status = 'Cancelled' then 1 else 0 end)/count(distinct order_id) as perc_cancellation_by_booking
  --round(sum(case when status= 'Cancelled' then gbv else 0 end)/sum(gbv)*100,2) as perc_cancellation_by_gbv
from allorders_app
group by 1,2
order by 4 desc
limit 30
-- allorders_funnel as
-- (
-- select
--   next_r as type,
--   count(distinct user_id) number_of_users
-- from allorders_app
-- group by 1
-- order by 1
-- limit 10
-- )
