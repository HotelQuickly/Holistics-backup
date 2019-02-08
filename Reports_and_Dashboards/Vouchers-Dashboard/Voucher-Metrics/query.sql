#standardsql
-- with redeemed as
-- (
-- select
-- voucher_code,
-- count(distinct user_id) as vouchers_redeemed
-- from
-- bi_export.user_vouchers
-- where 1=1
-- and voucher_status = 'Redeemed'
-- and [[ date(d70_voucher_redeemed_date) >= {{ date_range_start }} ]]
-- and [[ date(d70_voucher_redeemed_date) <= {{ date_range_end }} ]]
-- group by 1
-- )
-- ,
with metrics as
(
select
`bi_export.user_vouchers`.voucher_code,
d64_voucher_campaign_channel_code,
count(distinct `analyst.all_orders`.user_id) as used_vouchers,
sum(m07_selling_price_total_usd ) as GBV,
--m27_voucher_amount_usd as voucher_amount,
sum(vouchers_used_usd_amount_m74 ) as total_voucher_amount_used,
sum(m12_amount_of_commission_earned_usd) as commission ,
sum(m12_amount_of_commission_earned_usd) - sum(vouchers_used_usd_amount_m74 ) - 0.03*sum(m07_selling_price_total_usd ) as pc3,
sum(m07_selling_price_total_usd )/count(distinct `analyst.all_orders`.order_id) as abv
from
`analyst.all_orders`
left join
`bi_export.user_vouchers`
on 1=1
and `analyst.all_orders`.user_id = `bi_export.user_vouchers`.user_id
left join
bi_export.voucher
on 1=1
and `bi_export.user_vouchers`.voucher_code = voucher.voucher_code
where 1=1
and [[ lower(`bi_export.user_vouchers`.voucher_code) in  ( {{ voucher }} ) ]]
and `bi_export.user_vouchers`.voucher_code in (select * from ad_hoc_projects.voucher_list)
and voucher_status = 'Used'
and date(d71_voucher_used_date) = date( m01_order_datetime_gmt0 )
and [[ date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
and [[ date(m01_order_datetime_gmt0) <= {{ date_range_end }} ]]
and [[ lower(d64_voucher_campaign_channel_code) in ( {{ voucher_campaign_channel_ }} ) ]]
group by 1,2
)
select
user_vouchers.voucher_code,
voucher.d64_voucher_campaign_channel_code as voucher_campaign,
used_vouchers,
count(distinct case when voucher_status = 'Redeemed' then user_id end ) as redeemed_vouchers,
GBV,
total_voucher_amount_used,
commission,
pc3,
abv
from
bi_export.user_vouchers
Left join metrics
on 1=1
and metrics.voucher_code = user_vouchers.voucher_code
left join
bi_export.voucher
on 1=1
and user_vouchers.voucher_code = voucher.voucher_code
where 1=1
and voucher_status In ('Redeemed', 'Used')
and user_vouchers.voucher_code in (select * from ad_hoc_projects.voucher_list)
and (( [[ date(d70_voucher_redeemed_date) >= {{ date_range_start }} ]]
and [[ date(d70_voucher_redeemed_date) <= {{ date_range_end }} ]])
or ( [[ date(d71_voucher_used_date) >= {{date_range_start}} ]]
and [[ date(d71_voucher_used_date) <= {{ date_range_end }} ]] ))
and [[ lower(user_vouchers.voucher_code) in  ( {{ voucher }} ) ]]
and [[ lower(voucher.d64_voucher_campaign_channel_code) in ( {{ voucher_campaign_channel_ }} ) ]]
and user_vouchers.voucher_code is not null
group by 1,2,3,5,6,7,8,9
