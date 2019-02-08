#standardSQL
SELECT
date,
trivago_cost,
ta_cost,
hotelscombined_cost,
skyscanner_cost,
kayak_cost,
hotellook_cost
FROM
analyst.metasearch_cost
WHERE 1=1
[[ and date >= {{ date_range_start }} ]]
[[ and date <=  {{ date_range_end }}  ]]
ORDER BY 1 ASC
