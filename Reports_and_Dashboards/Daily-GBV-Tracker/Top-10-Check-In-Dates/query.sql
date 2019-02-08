#standardsql
select
m138_offer_checkin_date as Check_In_Date,
sum(m07_selling_price_total_usd) as GBV
from
analyst.all_orders
-- where 1=1
-- and date_diff(current_date, date(m01_order_datetime_gmt0), day) <= 30
-- and date_diff(m138_offer_checkin_date, current_date, day) <= 90
-- and date_diff(m138_offer_checkin_date, current_date, day) >= 0
group by 1
order by 2 DESC
LIMIT 20
