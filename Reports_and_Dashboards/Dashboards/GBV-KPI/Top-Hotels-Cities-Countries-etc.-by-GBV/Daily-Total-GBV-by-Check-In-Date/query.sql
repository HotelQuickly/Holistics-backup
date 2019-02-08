#standardSQL
SELECT
m138_offer_checkin_date as Check_In_Date,
ROUND(SUM(m07_selling_price_total_usd),0) as GBV
FROM analyst.all_orders
WHERE 1=1
[[ and m138_offer_checkin_date >= {{ date_range_start }} ]]
[[ and m138_offer_checkin_date <=  {{ date_range_end }}  ]]
GROUP BY 1
ORDER BY 1 ASC
