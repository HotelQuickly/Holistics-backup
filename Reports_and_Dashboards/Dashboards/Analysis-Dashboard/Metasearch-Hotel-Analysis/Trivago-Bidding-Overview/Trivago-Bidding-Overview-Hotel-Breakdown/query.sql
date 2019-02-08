#standardSQL
SELECT
CASE
-- WHEN clicks = 0 THEN 'A) 0 Clicks'
WHEN clicks > 0 and clicks = 1 THEN 'A) 1 Click'
WHEN clicks = 2 THEN 'B) 2 Clicks'
WHEN clicks = 3 THen 'C) 3 Clicks'
WHEN clicks > 3 AND clicks <= 10 THEN 'D) 4 - 10 Clicks'
WHEN clicks > 10 AND clicks <= 20 THEN 'E) 11 - 20 Clicks'
WHEN clicks > 20 AND clicks <= 30 THEN 'F) 21 - 30 Clicks'
WHEN clicks > 30 AND clicks <= 50 THEN 'G) 31 - 50 Clicks'
WHEN clicks > 50 THEN 'H) More than 51 Clicks' END AS Clicks,
count(distinct partner_ref) AS Hotels
FROM
(SELECT
partner_ref,
AVG(bid_cpc) as bid_eur,
AVG(bid_cpc*fx_rate.currency_rate) as avg_bid_usd,
SUM(hotel_impr) as hr_Impressions,
SUM(clicks) as clicks,
SUM(bookings) as hr_Bookings,
SUM(gross_rev*fx_rate.currency_rate) as hr_GBV,
SUM(cost*fx_rate.currency_rate) as hr_Cost,
(SUM(gross_rev*fx_rate.currency_rate)*0.108 - SUM(cost*fx_rate.currency_rate) - SUM(gross_rev*fx_rate.currency_rate)*0.03) as hr_Estimated_PC3,
(SAFE_DIVIDE(SUM(clicks),SUM(hotel_impr))) as hr_CTR,
(SAFE_DIVIDE(SUM(bookings),SUM(clicks))) as hr_Conversion,
(SAFE_DIVIDE(SUM(beat * hotel_impr),SUM((1-unavailability)*hotel_impr))) as hr_Percent_Beat,
-1*(SAFE_DIVIDE(SUM(1 - (unavailability * hotel_impr)),SUM(hotel_impr))) as hr_Availability
FROM `metasearch_trivago_report_raw.hotel_report_*` as hotel_report
LEFT JOIN hqdatawarehouse.bi_export.fx_rate ON 1=1
AND fx_rate.date = hotel_report.date
AND prim_currency_code = 'EUR'
AND scnd_currency_code = 'USD'
WHERE 1=1
and _TABLE_SUFFIX >= '20170101'
and date_diff(current_date,hotel_report.date, day) <= 31
GROUP BY 1
having clicks > 0
ORDER BY 1 DESC
)
GROUP BY 1
ORDER BY 1
