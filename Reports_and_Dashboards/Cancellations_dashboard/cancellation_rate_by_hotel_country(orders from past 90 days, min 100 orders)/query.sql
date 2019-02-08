#standardsql
select
d12_hotel_country_name as hotel_country,
--count(distinct order_id),
sum(case when d08_order_status_name = 'Cancelled' then m07_selling_price_total_usd end)/sum(m07_selling_price_total_usd) as cancellation_rate
from
analyst.all_orders
where date_diff(current_date, date(m01_order_datetime_gmt0),day) <= 90
and d12_hotel_country_name is not null
group by 1
having count(distinct order_id) > 100
order by 2 desc
limit 15
