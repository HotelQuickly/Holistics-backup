#standardsql
select
m138_offer_checkin_date as checkin_date,
sum(case when d58_user_base_country_name = 'United States' then m07_selling_price_total_usd end) as us_gbv,
sum(case when d58_user_base_country_name = 'Australia' then m07_selling_price_total_usd end) as au_gbv ,
sum(case when d58_user_base_country_name = 'Germany' then m07_selling_price_total_usd end) as de_gbv,
sum(case when d58_user_base_country_name = 'United Kingdom' then m07_selling_price_total_usd end) as uk_gbv,
sum(case when d58_user_base_country_name = 'Canada' then m07_selling_price_total_usd end) as ca_gbv,
sum(case when d58_user_base_country_name = 'South Korea' then m07_selling_price_total_usd end) as kr_gbv,
sum(case when d58_user_base_country_name not in ('United States', 'Australia' , 'Germany', 'United Kingdom', 'Canada', 'South Korea') then m07_selling_price_total_usd end) as others_gbv
from
analyst.all_orders
where 1=1
and date_diff(current_date, date(m01_order_datetime_gmt0), day) <= 90
and date_diff(m138_offer_checkin_date, current_date, day) <= 90
and date_diff(m138_offer_checkin_date, current_date, day) >= 0
group by 1
order by 1
