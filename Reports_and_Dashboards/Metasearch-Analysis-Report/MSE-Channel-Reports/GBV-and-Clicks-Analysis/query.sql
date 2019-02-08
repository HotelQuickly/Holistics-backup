#standardsql
with gbv as
(
select
  hotel_id,
  ifnull(sum(case when lower(d180_order_referral_source_code) = 'trivago' then m07_selling_price_total_usd end), 0) trivago_gbv,
  ifnull(sum(case when lower(d180_order_referral_source_code) = 'tripadvisor' then m07_selling_price_total_usd end), 0) ta_gbv
from analyst.all_orders
where 1=1
[[and date(m01_order_datetime_gmt0) >= {{date_range_start}}]]
[[and date(m01_order_datetime_gmt0) <= {{date_range_end}}]]
group by 1
),

tv_click as
(
select
  cast(partner_ref as int64) as hotel_id,
  hotel_name,
  city hotel_city,
  country hotel_country,
  sum(clicks) as trivago_clicks
from `metasearch_trivago_report_raw.hotel_report_*`
where 1=1
[[and _TABLE_SUFFIX >= format_date('%Y%m%d', {{date_range_start}}) ]]
[[and _TABLE_SUFFIX <= format_date('%Y%m%d', {{date_range_end}}) ]]
group by 1,2,3,4
order by 5 desc
),

ta_click as
(
select
  cast(location_id as int64) as hotel_id,
  d15_hotel_name hotel_name,
  d10_hotel_city_name hotel_city,
  d12_hotel_country_name hotel_country,
  sum(clicks) as ta_clicks
from `metasearch_tripadvisor_report_raw.click_cost_*`
left join bi_export.hotel b
on 1=1
and cast(location_id as int64) = b.hotel_id
where 1=1
[[and _TABLE_SUFFIX >= format_date('%Y%m%d', {{date_range_start}}) ]]
[[and _TABLE_SUFFIX <= format_date('%Y%m%d', {{date_range_end}}) ]]
group by 1,2,3,4
order by 5 desc
),

ta_tv as
(
select
  ifnull(ta.hotel_id, tv.hotel_id) hotel_id,
  ifnull(ta.hotel_name, tv.hotel_name) hotel_name,
  ifnull(ta.hotel_city, tv.hotel_city) hotel_city,
  ifnull(ta.hotel_country, tv.hotel_country) hotel_country,
  ifnull(ta_clicks, -1) ta_clicks,
  ifnull(trivago_clicks, -1) trivago_clicks
from ta_click ta
full join tv_click tv
on 1=1
and ta.hotel_id = tv.hotel_id
),

final as
(
select
  ta_tv.hotel_id,
  hotel_name,
  hotel_city,
  hotel_country,
  ta_clicks,
  ifnull(ta_gbv, 0) ta_gbv,
  trivago_clicks,
  ifnull(trivago_gbv, 0) trivago_gbv
from ta_tv
left join gbv
on ta_tv.hotel_id = gbv.hotel_id
order by ta_clicks desc
)

select * from final
