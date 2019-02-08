#standardsql
select
date_trunc(date_add(m138_offer_checkin_date, interval m03_count_of_nights_booked day) , {{ day_week_month|noquote }}) as checkout_date,
sum(m12_amount_of_commission_earned_usd) as commission
from
`analyst.all_orders`
where 1=1
and lower(d22_inventory_source_code) = 'expedia'
and d08_order_status_name = 'Active'
and [[ date_add(m138_offer_checkin_date, interval m03_count_of_nights_booked day) >= {{date_range_start}} ]]
and [[ date_add(m138_offer_checkin_date, interval m03_count_of_nights_booked day) <= {{date_range_end}} ]]
group by 1
order by 1 desc
