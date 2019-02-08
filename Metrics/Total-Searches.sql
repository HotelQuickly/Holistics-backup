-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

#standardsql
SELECT
sum(tsc)
FROM
`analyst.daily_tsc_tsac_*`
where
 {{time_where}}
 
