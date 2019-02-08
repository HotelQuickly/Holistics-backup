SELECT
CASE
WHEN nights = 1 THEN '1 Night'
WHEN nights = 2 THEN '2 Nights'
WHEN nights = 3 THEN '3 Nights'
WHEN nights = 4 THEN '4 Nights'
WHEN nights = 5 THEN '5 Nights'
WHEN nights = 6 THEn '6 Nights'
WHEN nights = 7 THEN '7 Nights'
ELSE '8 Or More Nights' END as Nights,
SUM(orders) as Bookings
FROM
(
select
m03_count_of_nights_booked as nights,
COUNT(distinct order_id) as orders
from
analyst.all_orders
where 1=1
and  [[ DATE(m01_order_datetime_gmt0) >= ({{ date_range_start }}) ]]
and  [[ DATE(m01_order_datetime_gmt0) <=  ({{ date_range_end }})  ]]
and  d181_business_platform_code = 'website'
group by 1
order by 1 asc
)
GROUP BY 1
ORDER BY 1
