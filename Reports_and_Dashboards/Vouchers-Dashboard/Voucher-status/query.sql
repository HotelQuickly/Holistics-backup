#standardsql
select
`bi_export.user_vouchers`.voucher_code,
d64_voucher_campaign_channel_code as voucher_campaign,
voucher_status,
count(distinct user_id) as count_of_vouchers
from
`bi_export.user_vouchers`
left join bi_export.voucher
on 1=1
and `bi_export.user_vouchers`.voucher_code = voucher.voucher_code
where 1=1
and [[ lower(`bi_export.user_vouchers`.voucher_code) in ( {{ voucher }} ) ]]
and `bi_export.user_vouchers`.voucher_code in (select * from ad_hoc_projects.voucher_list)
and [[ lower(d64_voucher_campaign_channel_code) in ( {{ voucher_campaign_channel_ }} ) ]]
group by 1,2,3
order by 1
