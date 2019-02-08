#standardsql
with chosen_date as
(
select
  date(m01_order_datetime_gmt0) report_date,
  d22_inventory_source_code inventory_source,
  count(distinct order_id) orders,
  round(sum(m07_selling_price_total_usd), 2) gbv
from `analyst.all_orders`
where 1=1
and [[ date(m01_order_datetime_gmt0) = {{ single_date }} ]]
group by 1,2
order by 4 desc
),

past1day as
(
select
  d22_inventory_source_code inventory_source,
  count(distinct order_id) orders,
  round(sum(m07_selling_price_total_usd), 2) gbv
from `analyst.all_orders`
where 1=1
and [[ date(m01_order_datetime_gmt0) = date_sub({{ single_date }}, interval 1 day) ]]
group by 1
order by 3 desc
),

past7day as
(
select
  d22_inventory_source_code inventory_source,
  count(distinct order_id) orders,
  round(sum(m07_selling_price_total_usd), 2) gbv
from `analyst.all_orders`
where 1=1
and [[ date(m01_order_datetime_gmt0) = date_sub({{ single_date }}, interval 7 day) ]]
group by 1
order by 3 desc
),

past1month as
(
select
  d22_inventory_source_code inventory_source,
  count(distinct order_id) orders,
  round(sum(m07_selling_price_total_usd), 2) gbv
from `analyst.all_orders`
where 1=1
and [[ date(m01_order_datetime_gmt0) = date_sub({{ single_date }}, interval 1 month) ]]
group by 1
order by 3 desc
),

past1year as
(
select
  d22_inventory_source_code inventory_source,
  count(distinct order_id) orders,
  round(sum(m07_selling_price_total_usd), 2) gbv
from `analyst.all_orders`
where 1=1
and [[ date(m01_order_datetime_gmt0) = date_sub({{ single_date }}, interval 1 year) ]]
group by 1
order by 3 desc
),

combined as
(
select
  report_date,
  a.inventory_source,
  a.orders bookings,
  concat(cast(round((a.orders-b.orders)/b.orders*100,2) as string), '%') bookings_1DA,
  concat(cast(round((a.orders-c.orders)/c.orders*100,2) as string), '%') bookings_7DA,
  concat(cast(round((a.orders-b.orders)/b.orders*100,2) as string), '%') bookings_1MA,
  concat(cast(round((a.orders-b.orders)/b.orders*100,2) as string), '%') bookings_1YA,
  a.gbv,
  concat(cast(round((a.gbv-b.gbv)/b.gbv*100,2) as string), '%') gbv_1DA,
  concat(cast(round((a.gbv-c.gbv)/c.gbv*100,2) as string), '%') gbv_7DA,
  concat(cast(round((a.gbv-d.gbv)/d.gbv*100,2) as string), '%') gbv_1MA,
  concat(cast(round((a.gbv-e.gbv)/e.gbv*100,2) as string), '%') gbv_1YA
from chosen_date a
join past1day b
on a.inventory_source = b.inventory_source
join past7day c
on a.inventory_source = c.inventory_source
join past1month d
on a.inventory_source = d.inventory_source
join past1year e
on a.inventory_source = e.inventory_source
order by a.gbv desc
)

select * from combined
