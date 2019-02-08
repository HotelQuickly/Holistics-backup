#standardsql
with
pc3_tbl as
(
SELECT
Date as pc3_date,
ROUND(SUM(PC3),0) as PC3
FROM
(
WITH gbv_data AS
(
SELECT
date(m01_order_datetime_gmt0) as Date1,
lower(d180_order_referral_source_code) as Channel1,
IFNULL(SUM(m07_selling_price_total_usd),0) as GBV,
IFNULL(SUM(m12_amount_of_commission_earned_usd),0) as Commission,
IFNULL(SUM(vouchers_used_usd_amount_m74),0) as vouchers
FROM `analyst.all_orders`
WHERE 1=1
and date(m01_order_datetime_gmt0) in (date_add(Current_date(), interval -1 DAY), date_add(Current_date(), interval -8 DAY))
GROUP BY 1,2
)
SELECT
gbv_data.date1 as Date,
Channel1,
CASE
  WHEN Channel1 = 'tripadvisor' THEN sum(commission)-sum(ta_cost)-sum(gbv*0.03)
  WHEN Channel1 = 'trivago' THEN sum(commission)-sum(trivago_cost)-sum(gbv*0.03)
  WHEN Channel1 = 'hotelscombined' THEN sum(commission)-sum(hotelscombined_cost)-sum(gbv*0.03)
  WHEN Channel1 = 'skyscanner' THEN sum(commission)-sum(gbv*0.15)
  WHEN Channel1 = 'kayak' THEN sum(commission)-sum(gbv*0.13)
  WHEN Channel1 = 'hotellook' THEN sum(commission)-sum(gbv*0.13)
  WHEN Channel1 = 'hqmobileapp' THEN sum(commission)-sum(vouchers) - sum(gbv*.03)
  WHEN Channel1 = 'hq-website' THEN sum(commission) - sum(gbv*.03)
  WHEN Channel1 = 'direct-booking-via-hct' THEN sum(commission)-sum(vouchers) - sum(gbv*.03)
  WHEN Channel1 = 'optimise-media-affiliate' THEN sum(commission) - sum(gbv*.11)
  WHEN Channel1 = 'partnership' THEN sum(commission) - sum(gbv*.10)
 END
  as PC3
FROM
gbv_data
  LEFT JOIN analyst.metasearch_cost ON 1=1
  AND metasearch_cost.date =  gbv_data.date1
WHERE 1=1
and date1 in (date_add(Current_date(), interval -1 DAY), date_add(Current_date(), interval -8 DAY))
GROUP BY 1,2
ORDER BY 1 ASC
)
group by 1
),

total_search as
(
select
  measured_date,
  sum(tsc) as tsc,
  sum(tsac) as tsac
from `inventory_raw.total_search_*`
where 1=1
and _TABLE_SUFFIX >= format_date("%Y%m%d", date_add(Current_date(), interval -9 DAY))
and measured_date in (date_add(Current_date(), interval -1 DAY), date_add(Current_date(), interval -8 DAY))
group by 1
),

total_clicks as
(
select
  date,
  sum(trivago_clicks) + sum(ta_clicks) as clicks
from `analyst.ta_trivago_daily_report_data`
where 1=1
and date in (date_add(Current_date(), interval -1 DAY), date_add(Current_date(), interval -8 DAY))
group by 1
),

mse_cost as
(
select
  date,
  trivago_cost + ta_cost + hotelscombined_cost + kayak_cost + skyscanner_cost + hotellook_cost as mse_cost
from `analyst.metasearch_cost`
where 1=1
and date in (date_add(Current_date(), interval -1 DAY), date_add(Current_date(), interval -8 DAY))
),

sessions as
(
select
  date(time) as session_date,
  count(distinct session_id) as session
from `metasearch.log_availability`
where 1=1
and date(time) in (date_add(Current_date(), interval -1 DAY), date_add(Current_date(), interval -8 DAY))
group by 1
),

allorders as
(
select
  date(m01_order_datetime_gmt0) as order_date,
  count(distinct order_id) as bookings,
  count(distinct case when lower(d181_business_platform_code) = 'metasearch' then order_id end) as mse_bookings,
  count(distinct case when lower(d181_business_platform_code) = 'app' then order_id end) as app_bookings,
  count(distinct case when lower(d181_business_platform_code) = 'website' then order_id end) as web_bookings,
  sum(m07_selling_price_total_usd) as gbv,
  SUM(m12_amount_of_commission_earned_usd) AS commission,
  sum(vouchers_used_usd_amount_m74) as voucher_cost
from `analyst.all_orders`
where 1=1
and date(m01_order_datetime_gmt0) in (date_add(Current_date(), interval -1 DAY), date_add(Current_date(), interval -8 DAY))
group by 1
),

combined_tbl as
(
select
  rank() over(order by order_date desc) as date_rank,
  order_date,
  tsc,
  lead(tsc,1,0) over(order by order_date desc) as prev_tsc,
  session,
  lead(session,1,0) over(order by order_date desc) as prev_session,
  mse_bookings,
  lead(mse_bookings,1,0) over(order by order_date desc) as prev_mse_bookings,
  app_bookings,
  lead(app_bookings,1,0) over(order by order_date desc) as prev_app_bookings,
  web_bookings,
  lead(web_bookings,1,0) over(order by order_date desc) as prev_web_bookings,
  gbv,
  lead(gbv,1,0) over(order by order_date desc) as prev_gbv,
  PC3 as est_pc3,
  lead(PC3, 1, 0) over(order by order_date desc) as prev_pc3,
  gbv/bookings as abv,
  lead(gbv/bookings,1,0) over(order by order_date desc) as prev_abv
from allorders a
left join total_clicks b
on 1=1
and a.order_date = b.date
left join total_search c
on 1=1
and a.order_date = c.measured_date
left join mse_cost d
on 1=1
and a.order_date = d.date
left join sessions e
on 1=1
and a.order_date = e.session_date
left join pc3_tbl f
on 1=1
and a.order_date = f.pc3_date
),

comparison_tbl as
(
select
  date_rank,
  order_date as report_date,
  tsc,
  round((tsc - prev_tsc)/prev_tsc*100, 2) as tsc_cmp,
  session,
  round((session - prev_session)/prev_session*100, 2) as session_cmp,
  mse_bookings,
  round((mse_bookings - prev_mse_bookings)/prev_mse_bookings*100, 2) as mse_bookings_cmp,
  app_bookings,
  round((app_bookings - prev_app_bookings)/prev_app_bookings*100, 2) as app_bookings_cmp,
  web_bookings,
  round((web_bookings - prev_web_bookings)/prev_web_bookings*100, 2) as web_bookings_cmp,
  round(gbv, 0) gbv,
  round((gbv - prev_gbv)/prev_gbv*100, 2) as gbv_cmp,
  round(est_pc3, 0) est_pc3,
  round((est_pc3 - prev_pc3)/abs(prev_pc3)*100, 2) as pc3_cmp,
  round(abv, 2) abv,
  round((abv - prev_abv)/prev_abv*100, 2) as abv_cmp
from combined_tbl
where 1=1
and date_rank = 1
),

formatted_tbl as
(
select
  date_rank,
  format_date("%d %B %Y", report_date) report_date,
  concat(cast(round(tsc/1000000,0) as string), 'M (', cast(tsc_cmp as string), '%)') as searches,
  concat(cast(session as string), ' (', cast(session_cmp as string), '%)') as sessions,
  concat(cast(mse_bookings as string), ' (', cast(mse_bookings_cmp as string), '%)') as mse_bookings,
  concat(cast(app_bookings as string), ' (', cast(app_bookings_cmp as string), '%)') as app_bookings,
  concat(cast(web_bookings as string), ' (', cast(web_bookings_cmp as string), '%)') as web_bookings,
  concat('$', cast(gbv as string), ' (', cast(gbv_cmp as string), '%)') as gbv,
  concat('$', cast(est_pc3 as string), ' (', cast(pc3_cmp as string), '%)') as est_pc3,
  concat('$', cast(abv as string), ' (', cast(abv_cmp as string), '%)') as abv
from comparison_tbl
),

pivoted_tbl as
(
select 1 as rank, 'Date' as metric, concat(cast(report_date as string), ' (Compared to 7 days before)') as values from formatted_tbl
union all
select 2, 'Searches', searches from formatted_tbl
union all
select 3, 'Sessions', sessions from formatted_tbl
union all
select 4, 'MSE Bookings', mse_bookings from formatted_tbl
union all
select 5, 'App Bookings', app_bookings from formatted_tbl
union all
select 6, 'Web Bookings', web_bookings from formatted_tbl
union all
select 7, 'GBV', gbv from formatted_tbl
union all
select 8, 'Estimated PC3', est_pc3 from formatted_tbl
union all
select 9, 'ABV', abv from formatted_tbl
order by 1
)

select metric,values from pivoted_tbl
