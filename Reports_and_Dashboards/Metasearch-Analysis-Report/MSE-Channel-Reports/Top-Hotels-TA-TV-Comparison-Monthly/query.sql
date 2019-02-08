#standardsql
with total as
(
select
  date_trunc(date(m01_order_datetime_gmt0), month) booking_month,
  hotel_id as hotel_id,
  d15_hotel_name as hotel_name,
  count(distinct order_id) total_bookings,
  round(sum(m07_selling_price_total_usd), 0) as total_gbv
from
analyst.all_orders
WHERE 1=1
and [[date(m01_order_datetime_gmt0) >= {{date_range_start}}]]
and [[date(m01_order_datetime_gmt0) <= {{date_range_end}}]]
--AND lower(d180_order_referral_source_code) IN ('trivago','tripadvisor')
group by 1,2,3
order by 1
),

total_ranked as
(
select
  a.*,
  rank() over(partition by booking_month order by total_gbv desc) as gbv_rank
from total a
order by booking_month, gbv_rank
),

ta as
(
select
  date_trunc(date(m01_order_datetime_gmt0), month) booking_month,
  hotel_id as hotel_id,
  d15_hotel_name as hotel_name,
  count(distinct order_id) ta_bookings,
  round(sum(m07_selling_price_total_usd), 0) as ta_gbv
from
analyst.all_orders
WHERE 1=1
and [[date(m01_order_datetime_gmt0) >= {{date_range_start}}]]
and [[date(m01_order_datetime_gmt0) <= {{date_range_end}}]]
AND lower(d180_order_referral_source_code) = 'tripadvisor'
group by 1,2,3
order by 1
),

ta_ranked as
(
select
  a.*,
  rank() over(partition by booking_month order by ta_gbv desc) as ta_rank
from ta a
order by booking_month, ta_rank
),

tv as
(
select
  date_trunc(date(m01_order_datetime_gmt0), month) booking_month,
  hotel_id as hotel_id,
  d15_hotel_name as hotel_name,
  count(distinct order_id) tv_bookings,
  round(sum(m07_selling_price_total_usd), 0) as tv_gbv
from
analyst.all_orders
WHERE 1=1
and [[date(m01_order_datetime_gmt0) >= {{date_range_start}}]]
and [[date(m01_order_datetime_gmt0) <= {{date_range_end}}]]
AND lower(d180_order_referral_source_code) = 'trivago'
group by 1,2,3
order by 1
),

tv_ranked as
(
select
  a.*,
  rank() over(partition by booking_month order by tv_gbv desc) as tv_rank
from tv a
order by booking_month, tv_rank
)

select
  a.booking_month,
  a.gbv_rank,
  a.hotel_id,
  a.hotel_name,
  a.total_gbv,
  concat(cast(round(safe_divide(ta_gbv,total_gbv)*100, 2) as string), '%') ta_gbv_perc,
  concat(cast(round(safe_divide(tv_gbv,total_gbv)*100, 2) as string), '%') tv_gbv_perc,
  ta_rank,
  tv_rank,
  total_bookings,
  ta_bookings,
  tv_bookings
from total_ranked a
left join ta_ranked b
on a.booking_month = b.booking_month
and a.hotel_id = b.hotel_id
left join tv_ranked c
on a.booking_month = c.booking_month
and a.hotel_id = c.hotel_id
where 1=1
and gbv_rank <= 200
order by 1,2
