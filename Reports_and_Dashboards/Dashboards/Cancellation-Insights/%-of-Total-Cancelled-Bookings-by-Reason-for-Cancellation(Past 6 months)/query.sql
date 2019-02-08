#standardsql
select
case when d166_order_cancelled_reason_code in ('TRIP_CANCELED', 'CHANGE_OF PLANS', 'FORCE_MAJEURE') then 'Trip Cancelled or Plan Change'
     when d166_order_cancelled_reason_code in ('FRAUD') then 'Fraud'
     when d166_order_cancelled_reason_code in ('BOOKED_WRONG DATE','ACCIDENTAL_BOOKING','BOOK_ANOTHER HOTEL','CHANGE_HOTEL') then 'Customers Fault or found another Hotel'
     when d166_order_cancelled_reason_code in ('INFORMATION_DISCREPANCY','BAD_HOTEL') then 'Information Discrepancy or Bad Hotel'
     when d166_order_cancelled_reason_code in ('WRONG_PAIRING_METASEARCH','WRONG_PAIRING_BEDS', 'WRONG_PAIRING_GTA','WRONG_PAIRING_DOTW','WRONG_PAIRING_EXP') then 'Wrong Pairing'
     when d166_order_cancelled_reason_code in ('CHEAPER_RATE') then 'Cheaper Rate'
     when d166_order_cancelled_reason_code in ('BANK_FEE','EXTRA_FEE','ADVANCE_PAYMENT','CHANGE_OF CURRENCY','CHANGE_CREDIT CARD') then 'Payment Issues'
     when d166_order_cancelled_reason_code in ('UNABLE_TO AMEND OR RE-BOOK: SUGGESTED CANCELLATION') then 'Unable to amend bookings'
     when d166_order_cancelled_reason_code in ('IT_ISSUE', 'DUPLICATE_BOOKINGS') then 'IT issue'
     when d166_order_cancelled_reason_code in ('UNCONFIRMED_BOOKING', 'CANNOT_ACCOMODATE_EXTRANET', 'CANNOT_ACCOMODATE_XML' ,'WAITING_OR_FAILED_FOR_LONG_TIME') then 'Unconfirmed Booking or Cannot Accomodate'
     when d166_order_cancelled_reason_code in ('TEST_BOOKING FROM THE HOTEL', 'PAYMENT_PENDING_FOR_LONG_TIME', 'OTHERS') Then 'Others'
     when d166_order_cancelled_reason_code in ('HCT_CONVERSION') then 'HCT Conversion' end as cancellation_reason,
count(distinct order_id) as bookings
from
analyst.all_orders
where
d08_order_status_name = 'Cancelled'
and date_diff(current_date, date(m01_order_datetime_gmt0), day) <= 180
group by 1
