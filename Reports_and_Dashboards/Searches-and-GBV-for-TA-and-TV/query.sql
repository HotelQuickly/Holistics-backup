#standardsql
with gbv1 as
(
select
date(m01_order_datetime_gmt0) as dt1,
d180_order_referral_source_code,
sum(m07_selling_price_total_usd) as gbv
from
analyst.all_orders
where
date(m01_order_datetime_gmt0) >= '2018-01-01'
and d180_order_referral_source_code in ('TRIVAGO','TRIPADVISOR')
group by 1,2
)
,
searches as
(
select
date as dt2,
consumer_code,
sum(tsc) as search
from
`analyst.daily_tsc_tsac_*`
where
_table_suffix >= '20180101'
and consumer_code in ('TRIVAGO','TRIPADVISOR')
group by 1,2
)
select
dt2,
consumer_code,
gbv,
search
from
searches
left join
gbv1
on 1=1
and dt2 = dt1
and d180_order_referral_source_code = consumer_code
group by 1,2,3,4
order by 1,2
