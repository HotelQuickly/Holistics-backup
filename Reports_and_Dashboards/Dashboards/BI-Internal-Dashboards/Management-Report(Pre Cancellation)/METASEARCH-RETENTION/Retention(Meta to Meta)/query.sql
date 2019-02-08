#standardsql
select *
from
management_report.retention_meta_to_meta
WHERE DATE_DIFF(DATE_TRUNC(current_date, month), DATE_TRUNC(first_booking_datetime, month),  month) >= 1
order by 1 desc
