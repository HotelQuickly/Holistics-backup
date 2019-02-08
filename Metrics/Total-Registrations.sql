-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}
#standardsql
SELECT
count (Distinct user_id)
FROM
bi_export.user
where {{time_where}}
