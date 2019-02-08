-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

SELECT
COUNT(DISTINCT session_id)
FROM metasearch.log_availability
WHERE 1=1
AND consumer_code IN ('kayak','hotelscombined','trivago','tripadvisor','hotellook','skyscanner')
AND {{time_where}}
