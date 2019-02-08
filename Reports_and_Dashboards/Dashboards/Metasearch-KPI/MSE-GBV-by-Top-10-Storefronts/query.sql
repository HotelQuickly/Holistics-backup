SELECT
date(m01_order_datetime_gmt0) AS Date,
sum(CASE WHEN d58_user_base_country_name = 'United States' THEN m07_selling_price_total_usd END) as USA,
sum(CASE WHEN d58_user_base_country_name = 'Australia' THEN m07_selling_price_total_usd END) as Australia,
sum(CASE WHEN d58_user_base_country_name = 'Germany' THEN m07_selling_price_total_usd END) as Germany,
sum(CASE WHEN d58_user_base_country_name = 'United Kingdom' THEN m07_selling_price_total_usd END) as United_Kingdom,
sum(CASE WHEN d58_user_base_country_name = 'South Korea' THEN m07_selling_price_total_usd END) as South_Korea,
sum(CASE WHEN d58_user_base_country_name = 'Japan' THEN m07_selling_price_total_usd END) as Japan,
sum(CASE WHEN d58_user_base_country_name = 'France' THEN m07_selling_price_total_usd END) as France,
sum(CASE WHEN d58_user_base_country_name = 'Spain' THEN m07_selling_price_total_usd END) as Spain,
sum(CASE WHEN d58_user_base_country_name = 'Italy' THEN m07_selling_price_total_usd END) as Italy,
sum(CASE WHEN d58_user_base_country_name = 'New Zealand' THEN m07_selling_price_total_usd END) as New_Zealand,
sum(CASE WHEN d58_user_base_country_name = 'Canada' THEN m07_selling_price_total_usd END) as Canada,
sum(CASE WHEN d58_user_base_country_name = 'Ireland' THEN m07_selling_price_total_usd END) as Ireland,
sum(CASE WHEN d58_user_base_country_name = 'Brazil' THEN m07_selling_price_total_usd END) as Brazil,
sum(CASE WHEN d58_user_base_country_name IS NULL THEN m07_selling_price_total_usd END) as Null_Entry,
sum(CASE WHEN d58_user_base_country_name NOT IN ('Ireland','Canada','New Zealand','France','Spain','Italy','Japan','South Korea','United Kingdom','Germany','Australia','United States','Brazil') THEN m07_selling_price_total_usd END) as Others
FROM analyst.all_orders
WHERE 1=1
AND {{ @Include_Relevant_Meta }}
[[ and date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
[[ and date(m01_order_datetime_gmt0) <=  {{ date_range_end }}  ]]
GROUP BY 1
ORDER BY 1 ASC
