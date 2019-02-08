#standardSQL
with chosen_date as
(
SELECT
  date(m01_order_datetime_gmt0) report_date,
  d58_user_base_country_name storefront,
  count(distinct order_id) AS bookings,
  sum(m07_selling_price_total_usd) AS gbv
FROM
analyst.all_orders
where 1=1
and lower(d180_order_referral_source_code) = 'trivago'
and [[ date(m01_order_datetime_gmt0) = {{ single_date }} ]]
group by 1,2
order by 4 desc
limit 30
),

past as
(
SELECT
  date(m01_order_datetime_gmt0) report_date,
  d58_user_base_country_name storefront,
  count(distinct order_id) AS bookings,
  sum(m07_selling_price_total_usd) AS gbv
FROM
analyst.all_orders
where 1=1
and lower(d180_order_referral_source_code) = 'trivago'
and [[ date(m01_order_datetime_gmt0) = date_sub({{ single_date }}, interval 7 day) ]]
group by 1,2
order by 4 desc
limit 30
),

chosen_rank as
(
select
  *,
  rank() over(order by gbv desc) ranking
from chosen_date
),

past_rank as
(
select
  *,
  rank() over(order by gbv desc) p_ranking
from past
),

combined as
(
select
  a.report_date,
  a.storefront,
  a.bookings,
  round((a.bookings-b.bookings)/b.bookings*100,2) bookings_perc,
  round(a.gbv, 2) gbv,
  round((a.gbv-b.gbv)/b.gbv*100,2) gbv_perc,
  a.ranking,
  b.p_ranking - a.ranking ranking_change,
  b.bookings p_bookings,
  b.gbv p_gbv,
  p_ranking
from chosen_rank a
left join past_rank b
on a.storefront = b.storefront
order by gbv desc
limit 10
),

final_table as
(
select
  report_date,
  storefront,
  concat(cast(bookings as string), ' (', cast(bookings_perc as string), '%)') as bookings,
  concat('$', cast(gbv as string), ' (', cast(gbv_perc as string), '%)') as gbv,
  ranking,
  ranking_change
from combined
order by ranking
)

-- select * from final_table
select
  report_date,
  storefront,
  bookings,
  gbv,
  case
    when ranking_change = 0 then concat(cast(ranking as string), ' (-)')
    when ranking_change > 0 then concat(cast(ranking as string), ' (+', cast(ranking_change as string), ')')
    when ranking_change < 0 then concat(cast(ranking as string), ' (', cast(ranking_change as string), ')')
  end as rank
from final_table
