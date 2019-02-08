#standardsql
with hotel_country_city as
(
select hotel_id,
d15_hotel_name,
d12_hotel_country_name,
d10_hotel_city_name
from `bi_export.hotel`
group by 1, 2, 3, 4
)
,
user_base_country as
(
select
lower(d57_user_base_country_code) AS d57_user_base_country_code,
d58_user_base_country_name
from
`bi_export.user`
group by 1,2
)
,
clicks as
(
select
date(time) as click_date,
count(distinct session_id) as click
from `metasearch.log_availability`
left join hotel_country_city
on 1=1
and `metasearch.log_availability`.hotel_id = hotel_country_city.hotel_id
left join user_base_country
on 1=1
and country_code = user_base_country.d57_user_base_country_code
where
[[ date(time)  >= {{ date_range_start }} ]]
and [[ date(time)  <=  {{ date_range_end }}  ]]
and [[hotel_country_city.d12_hotel_country_name in ( {{ hotel_country }} ) ]]
and [[hotel_country_city.d10_hotel_city_name in ( {{ hotel_city }} ) ]]
and [[user_base_country.d58_user_base_country_name in ( {{ user_base_country }} )]]
and [[consumer_code in  ( {{ channel }} )  ]]
and [[ cast(`metasearch.log_availability`.hotel_id as string) in ({{ hotel_id_test }}) ]]
group by 1
)
,
bookings as
(
select
date(m01_order_datetime_gmt0) as booking_date,
count(distinct order_id) as booking
from `analyst.all_orders`
where
[[ date(m01_order_datetime_gmt0)  >= {{ date_range_start }} ]]
and [[ date(m01_order_datetime_gmt0)  <=  {{ date_range_end }}  ]]
and [[d12_hotel_country_name in ( {{ hotel_country }} ) ]]
and [[d10_hotel_city_name in ( {{ hotel_city }} ) ]]
and [[d58_user_base_country_name in ( {{ user_base_country }} )]]
and [[lower(d180_order_referral_source_code) in ( {{channel}} ) ]]
and [[cast(`analyst.all_orders`.hotel_id as string) in ({{ hotel_id_test }}) ]]
group by 1
)
select
booking_date,
(sum(booking)/sum(click))*100 as booking_conversion
from
bookings right join clicks
on 1=1
and bookings.booking_date = clicks.click_date
group by 1
order by 1
