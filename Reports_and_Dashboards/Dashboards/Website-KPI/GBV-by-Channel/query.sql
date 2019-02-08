select
  date(m01_order_datetime_gmt0) as dt,
  case when d180_order_referral_source_code = 'GOOGLE-ADWORDS-WEB' or d180_order_referral_source_code = 'GOOGLE-ADWORDS-SEARCH' then 'GOOGLE ADWORDS'
       when d180_order_referral_source_code = 'DIRECT-BOOKING-VIA-HCT' or d180_order_referral_source_code = 'HCTS' then 'HCT'
       else d180_order_referral_source_code end as Channel,
  sum(m07_selling_price_total_usd) as GBV
from
  analyst.all_orders
where
  1 = 1
  and d181_business_platform_code = 'website'
  and [[ date(m01_order_datetime_gmt0) >= {{ date_range_start }} ]]
  and [[ date(m01_order_datetime_gmt0) <= {{ date_range_end }} ]]
group by 1,2
order by 1,2
