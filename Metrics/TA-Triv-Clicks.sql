-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

SELECT
ta_clicks+trivago_clicks
FROM analyst.ta_trivago_daily_report_data
WHERe {{time_where}}
