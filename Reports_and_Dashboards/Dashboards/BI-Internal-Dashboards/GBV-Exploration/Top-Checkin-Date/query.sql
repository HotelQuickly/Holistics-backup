#standardSQL
SELECT
m138_offer_checkin_date checkin_date,
date_diff(m138_offer_checkin_date, date(m01_order_datetime_gmt0), day) days_in_advance,
count(distinct order_id) AS orders,
sum(m07_selling_price_total_usd) AS gbv
FROM
analyst.all_orders
where 1=1
and [[ date(m01_order_datetime_gmt0) = {{ single_date }} ]]
group by 1,2
order by 4 desc
