#standardSQL
SELECT
CASE
WHEN bookings = 1 THEN 'A) 1 Booking'
WHEN bookings = 2 THEN 'B) 2 Bookings'
WHEN bookings = 3 THEN 'C) 3 Bookings'
WHEN bookings = 4 THEN 'D) 4 Bookings'
WHEN bookings = 5 THEN 'E) 5 Bookings'
WHEN bookings > 5 and bookings <= 10 THEN 'F) 6 - 10 Bookings'
WHEN bookings > 10 and bookings <= 20 THEN 'G) 11 - 20 Bookings'
WHEN bookings > 20 and bookings <= 50 THEN 'H) 21 - 50 Bookings'
WHEN bookings > 50 and bookings <= 100 THEN 'I) 51 - 100 Bookings'
ELSE 'J) 101 and More Bookings' END as Number_of_Bookings,
ROUND(SUM(results),0) as Total_Results
FROM
(

with
commission as
(
  SELECT
    hotel_id,
    COUNT(distinct order_id) as bookings,
    SUM(m12_amount_of_commission_earned_usd) as Commission
  FROM `analyst.all_orders`
  WHERE 1=1
  and Date(m01_order_datetime_gmt0) between '2018-04-01' and '2018-06-30'
  and lower(d180_order_referral_source_code) = 'trivago'
  and d58_user_base_country_name = 'Canada'
  GROUP BY 1
  HAVING bookings > 0
  ORDER BY 2 DESC
),

cost as
(
  select
    partner_ref as hotel_id,
    SUM(cost*fx_rate.currency_rate) as cost
  FROM `metasearch_trivago_report_raw.hotel_report_*` as hotel_report
  LEFT JOIN hqdatawarehouse.bi_export.fx_rate ON 1=1
  AND fx_rate.date = hotel_report.date
  AND prim_currency_code = 'EUR'
  AND scnd_currency_code = 'USD'
  where 1=1
  and _TABLE_SUFFIX between '20180401' and '20180630'
  and pos = 'CA'
  group by 1
)

select
  a.hotel_id,
  bookings,
  Commission,
  cost,
  Commission - cost as results
from commission a
join cost b
on a.hotel_id = cast(b.hotel_id as int64)
)
GROUP BY 1
ORDER BY 1 ASC
