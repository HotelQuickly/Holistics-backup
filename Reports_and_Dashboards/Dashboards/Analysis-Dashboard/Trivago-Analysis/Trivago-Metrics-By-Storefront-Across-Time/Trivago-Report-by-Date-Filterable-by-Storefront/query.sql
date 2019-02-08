#standardSQL
with allorders_tbl as
(
select
  m01_order_datetime_gmt0,
  d12_hotel_country_name,
  d58_user_base_country_name,
  country_name,
  m12_amount_of_commission_earned_usd,
  (CASE WHEN country_code = 'GB' THEN 'UK' ELSE country_code END) as country_code
from analyst.all_orders a
join `bi_export.lst_destination` b
on a.d58_user_base_country_name = b.country_name
where 1=1
AND lower(d180_order_referral_source_code) = 'trivago'
group by 1,2,3,4,5,6
),

commission_tbl as
(
SELECT
  DATE_TRUNC(date(m01_order_datetime_gmt0), {{ day_week_month|noquote }}) as order_date,
  sum(m12_amount_of_commission_earned_usd) as Commission
FROM allorders_tbl
WHERE 1=1
and [[ Date(m01_order_datetime_gmt0) >= {{ date_range_start }}]]
and [[ Date(m01_order_datetime_gmt0) <= {{ date_range_end }}]]
and [[ upper(d12_hotel_country_name) IN ({{ trivago_hotel_country }}) ]]
and [[ country_code in {{ trivago_storefront }} ]]
group by 1
),

tr_report as
(
SELECT
DATE_TRUNC(hotel_report.date, {{ day_week_month|noquote }}) AS report_date,
SUM(hotel_impr) as Impressions,
SUM(clicks) as Clicks,
SUM(bookings) as Bookings,
SUM(gross_rev*fx_rate.currency_rate) as GBV,
SUM(cost*fx_rate.currency_rate) as Cost,
SUM(cost*fx_rate.currency_rate) + SUM(gross_rev*fx_rate.currency_rate)*0.03 as Total_Cost,
(SAFE_DIVIDE(SUM(clicks),SUM(hotel_impr))) as CTR,
(SAFE_DIVIDE(SUM(bookings),SUM(clicks))) as Conversion,
(SAFE_DIVIDE(SUM(beat * hotel_impr),SUM((1-unavailability)*hotel_impr))) as Percent_Beat,
-1*(SAFE_DIVIDE(SUM(1 - (unavailability * hotel_impr)),SUM(hotel_impr))) as Availability
FROM `metasearch_trivago_report_raw.hotel_report_*` as hotel_report
LEFT JOIN hqdatawarehouse.bi_export.fx_rate ON 1=1
AND fx_rate.date = hotel_report.date
AND prim_currency_code = 'EUR'
AND scnd_currency_code = 'USD'
WHERE 1=1
and _TABLE_SUFFIX >= '20161018'
and [[ hotel_report.date >= {{ date_range_start }} ]]
and [[ hotel_report.date <= {{ date_range_end }} ]]
and [[ hotel_report.pos IN ({{ trivago_storefront }}) ]]
and [[ hotel_report.country IN ({{ trivago_hotel_country }}) ]]
GROUP BY 1
ORDER BY 1 DESC
),

final as
(
select
report_date,
Impressions,
Clicks,
Bookings,
GBV,
Cost,
Commission - Total_Cost as PC3,
SAFE_DIVIDE((Commission - Total_Cost), GBV) as PC3_as_a_Percent_of_GBV,
CTR,
Conversion,
Percent_Beat,
Availability
from tr_report tr
left join commission_tbl c
on 1=1
and tr.report_date = c.order_date
group by 1,2,3,4,5,6,7,8,9,10,11,12
order by 1 desc
)

select * from final
