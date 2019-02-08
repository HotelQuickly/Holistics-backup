#standardsql
select
hotel_created_month as months,
sum(xml_hotels_added) as xml_hotels_added,
sum(direct_hotels_added) as direct_hotels_added
from
management_report.hotels_added_direct_xml_split
where 1=1
AND DATE_DIFF(DATE_TRUNC(current_date, month), DATE_TRUNC(hotel_created_month, month),  month) >= 1
group by 1
order by 1 desc
