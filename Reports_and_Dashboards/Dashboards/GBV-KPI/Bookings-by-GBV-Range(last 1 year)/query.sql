#standardsql
select
case when m07_selling_price_total_usd < 50 then 'a) 0-50'
     when m07_selling_price_total_usd > 50 and m07_selling_price_total_usd < 100 then 'b) 50-100'
     when m07_selling_price_total_usd > 100 and m07_selling_price_total_usd < 250 then 'c) 100-250'
     when m07_selling_price_total_usd > 250 and m07_selling_price_total_usd < 500 then 'd) 250-500'
     when m07_selling_price_total_usd > 500 and m07_selling_price_total_usd < 1000 then 'e) 500-1000'
     when m07_selling_price_total_usd > 1000 then 'f) >1000'
end as gbv_range,
count(distinct order_id) as bookings
from
analyst.all_orders
where
date_diff(current_date, date(m01_order_datetime_gmt0), day) <= 365
group by 1
having gbv_range is not null
order by 1
