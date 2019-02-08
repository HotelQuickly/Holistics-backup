#standardsql
select
d12_hotel_country_name as hotel_country_name,
`bi_export.user_vouchers`.voucher_code,
booking_number_d110 as booking_number,
d22_inventory_source_code as inventory_source,
sum(m07_selling_price_total_usd ) as GBV,
sum(vouchers_used_usd_amount_m74 ) as total_voucher_amount_used,
sum(m208_source_price_usd ) as source_price
from
`analyst.all_orders`
left join
`bi_export.user_vouchers`
on 1=1
and `analyst.all_orders`.order_id = `bi_export.user_vouchers`.order_id
where 1=1
and [[ date(m01_order_datetime_gmt0 ) >= ( {{ date_range_start }} ) ]]
and [[ date(m01_order_datetime_gmt0 ) <= ( {{ date_range_end }} ) ]]
and [[ d12_hotel_country_name in ( {{ hotel_country}} ) ]]
and `bi_export.user_vouchers`.voucher_code in (select * from `ad_hoc_projects.voucher_list` )
and `bi_export.user_vouchers`.voucher_code is not null
group by 1,2,3,4
