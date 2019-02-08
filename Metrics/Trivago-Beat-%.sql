-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

#standardSQL
SELECT
trivago_beat_percent_wa
FROM `analyst.ta_trivago_daily_report_data`
WHERE {{time_where}}
