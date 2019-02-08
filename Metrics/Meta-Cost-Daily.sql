-- Please write a query that returns a single number value
-- Example: count the number of sign up
-- select count(1) from accounts where {{time_where}}

 #standardSQL
SELECT
round(SUM(trivago_cost+ta_cost+hotelscombined_cost+kayak_cost+skyscanner_cost+hotellook_cost), 0)
FROM analyst.metasearch_cost
WHERE {{time_where}}
