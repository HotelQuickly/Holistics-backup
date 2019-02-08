#standardsql
with
ytd as
(
select
  date(m01_order_datetime_gmt0) report_date,
  hotel_id,
  d15_hotel_name hotel_name,
  d10_hotel_city_name hotel_city,
  d12_hotel_country_name hotel_country,
  count(distinct order_id) bookings,
  round(sum(m07_selling_price_total_usd), 2) gbv
from `analyst.all_orders`
where 1=1
and date(m01_order_datetime_gmt0) = date_sub(current_date(), interval 110 DAY)
group by 1,2,3,4,5
order by 6 desc
),
ytd1 as
(
select
  date(m01_order_datetime_gmt0) report_date,
  hotel_id,
  d15_hotel_name hotel_name,
  d10_hotel_city_name hotel_city,
  d12_hotel_country_name hotel_country,
  count(distinct order_id) bookings,
  sum(m07_selling_price_total_usd) gbv
from `analyst.all_orders`
where 1=1
and date(m01_order_datetime_gmt0) = date_sub(current_date(), interval 120 DAY)
group by 1,2,3,4,5
order by 6 desc
),
ytd2 as
(
select
  date(m01_order_datetime_gmt0) report_date,
  hotel_id,
  d15_hotel_name hotel_name,
  d10_hotel_city_name hotel_city,
  d12_hotel_country_name hotel_country,
  count(distinct order_id) bookings,
  sum(m07_selling_price_total_usd) gbv
from `analyst.all_orders`
where 1=1
and date(m01_order_datetime_gmt0) = date_sub(current_date(), interval 130 DAY)
group by 1,2,3,4,5
order by 6 desc
),
ytd3 as
(
select
  date(m01_order_datetime_gmt0) report_date,
  hotel_id,
  d15_hotel_name hotel_name,
  d10_hotel_city_name hotel_city,
  d12_hotel_country_name hotel_country,
  count(distinct order_id) bookings,
  sum(m07_selling_price_total_usd) gbv
from `analyst.all_orders`
where 1=1
and date(m01_order_datetime_gmt0) = date_sub(current_date(), interval 104 DAY)
group by 1,2,3,4,5
order by 6 desc
),
ytd4 as
(
select
  date(m01_order_datetime_gmt0) report_date,
  hotel_id,
  d15_hotel_name hotel_name,
  d10_hotel_city_name hotel_city,
  d12_hotel_country_name hotel_country,
  count(distinct order_id) bookings,
  sum(m07_selling_price_total_usd) gbv
from `analyst.all_orders`
where 1=1
and date(m01_order_datetime_gmt0) = date_sub(current_date(), interval 150 DAY)
group by 1,2,3,4,5
order by 6 desc
),
ytd5 as
(
select
  date(m01_order_datetime_gmt0) report_date,
  hotel_id,
  d15_hotel_name hotel_name,
  d10_hotel_city_name hotel_city,
  d12_hotel_country_name hotel_country,
  count(distinct order_id) bookings,
  sum(m07_selling_price_total_usd) gbv
from `analyst.all_orders`
where 1=1
and date(m01_order_datetime_gmt0) = date_sub(current_date(), interval 160 DAY)
group by 1,2,3,4,5
order by 6 desc
),
ytd6 as
(
select
  date(m01_order_datetime_gmt0) report_date,
  hotel_id,
  d15_hotel_name hotel_name,
  d10_hotel_city_name hotel_city,
  d12_hotel_country_name hotel_country,
  count(distinct order_id) bookings,
  sum(m07_selling_price_total_usd) gbv
from `analyst.all_orders`
where 1=1
and date(m01_order_datetime_gmt0) = date_sub(current_date(), interval 170 DAY)
group by 1,2,3,4,5
order by 6 desc
),
ytd15 as
(
select
  date(m01_order_datetime_gmt0) report_date,
  hotel_id,
  d15_hotel_name hotel_name,
  d10_hotel_city_name hotel_city,
  d12_hotel_country_name hotel_country,
  count(distinct order_id) bookings,
  sum(m07_selling_price_total_usd) gbv
from `analyst.all_orders`
where 1=1
and date(m01_order_datetime_gmt0) = date_sub(current_date(), interval 15 DAY)
group by 1,2,3,4,5
order by 6 desc
),
ytd30 as
(
select
  date(m01_order_datetime_gmt0) report_date,
  hotel_id,
  d15_hotel_name hotel_name,
  d10_hotel_city_name hotel_city,
  d12_hotel_country_name hotel_country,
  count(distinct order_id) bookings,
  sum(m07_selling_price_total_usd) gbv
from `analyst.all_orders`
where 1=1
and date(m01_order_datetime_gmt0) = date_sub(current_date(), interval 31 DAY)
group by 1,2,3,4,5
order by 6 desc
),
ytdrank as
(
select
  *,
  rank() over(order by bookings desc, gbv desc) rank
from ytd
order by bookings desc, gbv desc
),
ytd1rank as
(
select
  *,
  rank() over(order by bookings desc, gbv desc) rank
from ytd1
order by bookings desc, gbv desc
),
ytd2rank as
(
select
  *,
  rank() over(order by bookings desc, gbv desc) rank
from ytd2
order by bookings desc, gbv desc
),
ytd3rank as
(
select
  *,
  rank() over(order by bookings desc, gbv desc) rank
from ytd3
order by bookings desc, gbv desc
),
ytd4rank as
(
select
  *,
  rank() over(order by bookings desc, gbv desc) rank
from ytd4
order by bookings desc, gbv desc
),
ytd5rank as
(
select
  *,
  rank() over(order by bookings desc, gbv desc) rank
from ytd5
order by bookings desc, gbv desc
),
ytd6rank as
(
select
  *,
  rank() over(order by bookings desc, gbv desc) rank
from ytd6
order by bookings desc, gbv desc
),
ytd15rank as
(
select
  *,
  rank() over(order by bookings desc, gbv desc) rank
from ytd15
order by bookings desc, gbv desc
),
ytd30rank as
(
select
  *,
  rank() over(order by bookings desc, gbv desc) rank
from ytd30
order by bookings desc, gbv desc
),
combined as
(
select
  a.report_date,
  a.hotel_id,
  a.hotel_name,
  a.hotel_city,
  a.hotel_country,
  a.bookings,
  a.gbv,
  a.rank rank_ytd,
  case when b.rank is null then '-' else cast(b.rank as string) end rank_2days_ago,
  case when c.rank is null then '-' else cast(c.rank as string) end rank_3days_ago,
  case when d.rank is null then '-' else cast(d.rank as string) end rank_4days_ago,
  case when e.rank is null then '-' else cast(e.rank as string) end rank_5days_ago,
  case when f.rank is null then '-' else cast(f.rank as string) end rank_6days_ago,
  case when g.rank is null then '-' else cast(g.rank as string) end rank_7days_ago,
  case when h.rank is null then '-' else cast(h.rank as string) end rank_15days_ago,
  case when i.rank is null then '-' else cast(i.rank as string) end rank_30days_ago
from ytdrank a
left join ytd1rank b
on 1=1
and a.hotel_id = b.hotel_id
and a.hotel_name = b.hotel_name
and a.hotel_city = b.hotel_city
and a.hotel_country = b.hotel_country
left join ytd2rank c
on 1=1
and a.hotel_id = c.hotel_id
and a.hotel_name = c.hotel_name
and a.hotel_city = c.hotel_city
and a.hotel_country = c.hotel_country
left join ytd3rank d
on 1=1
and a.hotel_id = d.hotel_id
and a.hotel_name = d.hotel_name
and a.hotel_city = d.hotel_city
and a.hotel_country = d.hotel_country
left join ytd4rank e
on 1=1
and a.hotel_id = e.hotel_id
and a.hotel_name = e.hotel_name
and a.hotel_city = e.hotel_city
and a.hotel_country = e.hotel_country
left join ytd5rank f
on 1=1
and a.hotel_id = f.hotel_id
and a.hotel_name = f.hotel_name
and a.hotel_city = f.hotel_city
and a.hotel_country = f.hotel_country
left join ytd6rank g
on 1=1
and a.hotel_id = g.hotel_id
and a.hotel_name = g.hotel_name
and a.hotel_city = g.hotel_city
and a.hotel_country = g.hotel_country
left join ytd15rank h
on 1=1
and a.hotel_id = h.hotel_id
and a.hotel_name = h.hotel_name
and a.hotel_city = h.hotel_city
and a.hotel_country = h.hotel_country
left join ytd30rank i
on 1=1
and a.hotel_id = i.hotel_id
and a.hotel_name = i.hotel_name
and a.hotel_city = i.hotel_city
and a.hotel_country = i.hotel_country
order by a.rank
limit 30
),
avg_buy_sell as
(
SELECT
hotel_id,
AVG(m07_selling_price_total_usd/m03_count_of_nights_booked) as avg_selling_price_per_night,
AVG(m208_source_price_usd/m03_count_of_nights_booked) as avg_buying_price_per_night
FROM analyst.all_orders
WHERE date(m01_order_datetime_gmt0) = DATE_ADD(current_date, INTERVAL -1 day)
GROUP BY 1
),
cgp as
(
SELECT
hq_hotel_id,
AVG
((select min(a) as cgp from (SELECT * FROM UNNEST([cgp_DOTW01, cgp_GTA01, cgp_HOTELBEDS01]) as a))/nights) as hq_cgp_price, -- only take price from dotw, gta, hotelbeds
avg(
((select min(a) as cgp from (SELECT * FROM UNNEST([cgp_DOTW01, cgp_GTA01, cgp_HOTELBEDS01]) as a))/nights - (select min(a) as cop from (SELECT * FROM UNNEST([cop_DOTW01, cop_GTA01, cop_HOTELBEDS01]) as a))/nights)/
((select min(a) as cgp from (SELECT * FROM UNNEST([cgp_DOTW01, cgp_GTA01, cgp_HOTELBEDS01]) as a))/nights)*100
) hq_markup
FROM `inventory_raw.search_*`
WHERE 1=1
AND _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY))
GROUP BY 1
),
-- QUERY TO GET EXPEDIA PRICE
-- expedia as
-- (
--  SELECT
-- *
-- FROM
-- (
-- SELECT
-- DATE(measured_datetime),
-- hq_hotel_id,
-- ROUND(100*avg
-- ((cop_EXPEDIA01/nights
-- - (select min(a) as cop from (SELECT * FROM UNNEST([cop_HQ01, cop_AGODAPARSER01, cop_DOTW01, cop_GTA01, cop_HOTELBEDS01, cop_SITEMINDER01, cop_ZUMATA01]) as a))/nights)/
-- (select min(a) as cop from (SELECT * FROM UNNEST([cop_HQ01, cop_AGODAPARSER01, cop_DOTW01, cop_GTA01, cop_HOTELBEDS01, cop_SITEMINDER01, cop_ZUMATA01]) as a))/nights),2) as discount_from_expedia
-- FROM `inventory_raw.search_*`
-- WHERE 1=1
-- AND _TABLE_SUFFIX >= FORMAT_DATE("%Y%m%d", DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY))
-- AND cop_EXPEDIA01 IS NOT NULL
-- GROUP BY 1,2
-- HAVING COUNT(cop_EXPEDIA01/nights) > 10
-- )
-- WHERE discount_from_expedia IS NOT NULL
-- ORDER BY discount_from_expedia ASC
-- ),
rg as(
select
  report_date,
  FORMAT_DATE('%A', report_date) AS dow,
  hq_hotel_id,
  avg(cheapest_price_on_channel) rg_cheapest
from `rategain.daily_price_comp_*`
where 1=1
and report_date >= date_sub(Current_date(), interval 15 DAY)
group by 1,2,3
order by 1,2,3
),
everyday as
(
select
  date queried_date,
  format_date('%A', date) as dow,
  hq_hotel_id
from `bi_export.date`, `rategain.daily_price_comp_*`
where date between date_sub(current_date(), interval 15 DAY) and date_sub(Current_date(), interval 1 DAY)
group by 1,2,3
),
rg_daily as
(
select
  queried_date,
  a.dow,
  a.hq_hotel_id,
  rg_cheapest,
  lag(rg_cheapest,1,0) over(partition by a.hq_hotel_id order by queried_date) rg_cheapest_1da,
  lag(rg_cheapest,2,0) over(partition by a.hq_hotel_id order by queried_date) rg_cheapest_2da
from everyday a
left join rg b
on 1=1
and queried_date = report_date
and a.hq_hotel_id = b.hq_hotel_id
),

final as
(
select
  a.*,
  round(b.avg_selling_price_per_night, 2) customer_booking_price,
--   Round(b.avg_buying_price_per_night, 2) supplier_source_price,
  round(c.hq_cgp_price, 2) customer_search_price,
--   case when d.discount_from_expedia is not null then concat(cast(d.discount_from_expedia as string), '%') end discount_from_expedia,
  round(case
    when rg_cheapest is not null then rg_cheapest
    when rg_cheapest is null and rg_cheapest_1da is not null then rg_cheapest_1da
    when rg_cheapest is null and rg_cheapest_1da is null then rg_cheapest_2da
    else -1
  end, 2) competitor_price,
  hq_markup
from combined a
left join avg_buy_sell b
on a.hotel_id = b.hotel_id
left join cgp c
on a.hotel_id = c.hq_hotel_id
-- left join expedia d
-- on a.hotel_id = d.hq_hotel_id
left join rg_daily e
on 1=1
and a.hotel_id = e.hq_hotel_id
and a.report_date = e.queried_date
order by rank_ytd
)

select
  a.report_date,
  a.hotel_id,
  a.hotel_name,
  a.hotel_city,
  a.hotel_country,
  a.bookings,
  a.gbv,
  a.rank_ytd,
  a.rank_2days_ago,
  a.rank_3days_ago,
  a.rank_4days_ago,
  a.rank_5days_ago,
  a.rank_6days_ago,
  a.rank_7days_ago,
  a.rank_15days_ago,
  a.rank_30days_ago,
  a.customer_booking_price,
  a.customer_search_price,
  a.competitor_price,
  customer_search_price - competitor_price price_diff,
  -- hq_markup / 100 * customer_search_price markup_price,
  case
    when competitor_price is null then 'null'
    when customer_search_price - competitor_price < 0 then 'yes, hq cheaper'
    when (customer_search_price - competitor_price > 0) and (customer_search_price - competitor_price < hq_markup * customer_search_price / 100) then 'yes'
    else 'no'
  end is_adjustable
from final a
order by rank_ytd
