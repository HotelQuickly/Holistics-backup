#standardSQL
SELECT
date_trunc(date, month) as order_month,
round(sum(trivago_cost),0) as Trivago,
round(sum(ta_cost),0) as TripAdvisor,
round(sum(hotelscombined_cost),0) as HotelsCombined,
round(sum(skyscanner_cost),0) as Skyscanner,
round(sum(kayak_cost),0) as Kayak,
round(sum(hotellook_cost),0) as HotelLook
FROM
analyst.metasearch_cost
WHERE 1=1
AND DATE_DIFF(DATE_TRUNC(current_date, month), DATE_TRUNC(date, month),  month) >= 1
AND date_trunc(date, month) >= '2017-04-01'
GROUP BY 1
ORDER BY 1 DESC
