#standardSQL
SELECT
Weekday,
AVG(number),
ROUND(AVG(GBV),0) as Avg_GBV
FROM
(SELECT
m138_offer_checkin_date,
FORMAT_DATE("%A" , m138_offer_checkin_date) as Weekday,
CAST(FORMAT_DATE("%u" , m138_offer_checkin_date) as INT64) as number,
SUM(m07_selling_price_total_usd) as GBV
FROM `analyst.all_orders`
WHERE m138_offer_checkin_date >= '2018-01-01'
AND m138_offer_checkin_date <= Current_Date()
GROUP BY 1,2,3
ORDER BY 2
)
GROUP BY 1
ORDER BY 2
