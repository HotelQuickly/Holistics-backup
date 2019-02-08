#standardsql
select
d58_user_base_country_name as user_base_country,
--count(distinct order_id),
sum(case when d08_order_status_name = 'Cancelled' then m07_selling_price_total_usd end)/sum(m07_selling_price_total_usd) as cancellation_rate
from
analyst.all_orders
where date_diff(current_date, date(m01_order_datetime_gmt0),day) <= 90
group by 1
having count(distinct order_id) > 100
order by 2 desc
limit 15
