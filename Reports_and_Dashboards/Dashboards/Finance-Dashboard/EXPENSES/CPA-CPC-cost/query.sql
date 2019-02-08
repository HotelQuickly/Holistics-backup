#standardsql
with kayak_ss_hl as
(
select
date_trunc(date_add(m138_offer_checkin_date, interval m03_count_of_nights_booked day), {{ day_week_month|noquote }}) as checkout_date,
IFNULL(SUM(CASE WHEN lower(d180_order_referral_source_code) = 'skyscanner' THEN(m07_selling_price_total_usd) END)*0.12,0) as skyscanner_cost,
IFNULL(SUM(CASE WHEN lower(d180_order_referral_source_code) = 'kayak' THEN(m07_selling_price_total_usd) END)*0.10,0) as kayak_cost,
IFNULL(SUM(CASE WHEN lower(d180_order_referral_source_code) = 'hotellook' THEN(m07_selling_price_total_usd) END)*0.10,0) as hotellook_cost
from
`analyst.all_orders`
where
d08_order_status_name = 'Active'
and [[ date_add(m138_offer_checkin_date, interval m03_count_of_nights_booked day) >= {{date_range_start}} ]]
and [[ date_add(m138_offer_checkin_date, interval m03_count_of_nights_booked day) <= {{date_range_end}} ]]
group by 1
)
,
hotelscombined as
(
with all_commission as
(
select
date_trunc(date(m01_order_datetime_gmt0), {{ day_week_month|noquote }}) as order_date,
IFNULL(
  0.9*
  (SUM(CASE WHEN lower(d180_order_referral_source_code) = 'hotelscombined' THEN(m12_amount_of_commission_earned_usd) END)
  -
  SUM(CASE WHEN lower(d180_order_referral_source_code) = 'hotelscombined' THEN(m07_selling_price_total_usd) END)*0.03)
  ,0) as today_commission_paid
from
`analyst.all_orders`
where 1=1
and [[ date(m01_order_datetime_gmt0 ) >= {{date_range_start}} ]]
and [[ date(m01_order_datetime_gmt0 ) <= {{date_range_end}} ]]
group by 1
)
,
cancelled_commission as
(
select
date_trunc(date(m171_order_cancelled_datetime_gmt0),{{ day_week_month|noquote }}) as cancelled_date,
IFNULL(
  0.9*(SUM(CASE WHEN lower(d180_order_referral_source_code) = 'hotelscombined' THEN(m12_amount_of_commission_earned_usd) END)
  -
  SUM(CASE WHEN lower(d180_order_referral_source_code) = 'hotelscombined' THEN(m07_selling_price_total_usd) END)*0.03)
  ,0) as today_cancelled_commission
from
`analyst.all_orders`
where
d08_order_status_name = 'Cancelled'
and [[ date(m171_order_cancelled_datetime_gmt0) >= {{date_range_start}} ]]
and [[ date(m171_order_cancelled_datetime_gmt0) <= {{date_range_end}} ]]
group by 1
)
select
order_date,
(today_commission_paid
-
today_cancelled_commission) as hotelscombined_cost
from
all_commission
left join
cancelled_commission
on 1=1
and order_date = cancelled_date
order by 1 desc
)
,
ta as
(
select
date_trunc(ds,{{ day_week_month|noquote }}) as ds,
sum(spend_usd) as tripadvisor_cost
from
`metasearch_tripadvisor_report_raw.bmp_bucket_*`
where 1=1
and [[ ds >= {{date_range_start}} ]]
and [[ ds <= {{date_range_end}} ]]
group by 1
order by 1 desc
)
,
trivago as
(
select
date_trunc(`metasearch_trivago_report_raw.hotel_report_*`.date, {{ day_week_month|noquote }}) as dt,
sum(cost*currency_rate) as trivago_cost
from
`metasearch_trivago_report_raw.hotel_report_*`
left join
`bi_export.fx_rate`
on 1=1
and `metasearch_trivago_report_raw.hotel_report_*`.date = `bi_export.fx_rate`.date
where prim_currency_code = 'EUR'
and scnd_currency_code = 'USD'
and [[ `metasearch_trivago_report_raw.hotel_report_*`.date >= {{date_range_start}} ]]
and [[ `metasearch_trivago_report_raw.hotel_report_*`.date <= {{date_range_end}} ]]
group by 1
order by 1 desc
)
select
order_date,
hotelscombined_cost,
trivago_cost,
tripadvisor_cost,
skyscanner_cost,
kayak_cost,
hotellook_cost
from hotelscombined
left join kayak_ss_hl
on 1=1
and order_date = checkout_date
left join ta
on 1=1
and order_date = ds
left join trivago
on 1=1
and order_date = dt
order by 1 desc
