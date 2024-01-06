SET SERVEROUTPUT ON;
set autoprint on;

-- feature 1
EXECUTE add_customer('Clinton', '829 Taylor Lane', 22256, 'Texas', 'adashdak@gmail.com', 82);
EXECUTE add_customer('Clinton', '830 Taylor Lane', 22234, 'Texas', 'adashdak@gmail.com', 82);

/

-- feature 2
EXECUTE check_email('rohanp@gmail.com');
EXECUTE check_email('tonystark@gmail.com');

/

--- feature 3
EXECUTE check_restaurant_by_category('sea');

/

--- feature 4
EXECUTE check_id('403');
EXECUTE check_id('409');

/

--- feature 5
-- can conflict with later features (CreateTables.sql rerun required).
EXECUTE check_cartid('701');
EXECUTE check_cartid('708');

/

--- feature 6
-- disg quantity for 701/501 is 21, it should be now reduced to 20
EXECUTE check_quantity('701', '501');
-- dish quantity for 702/502 is 1, will be removed now
EXECUTE check_quantity('702', '502');

/

--- feature 7
EXECUTE update_status(806,2,timestamp '2022-11-13 10:09:00.00');
EXECUTE update_status(801,2,timestamp '2022-11-13 10:09:00.00');
EXECUTE update_status(802,2,timestamp '2022-11-14 10:11:00.00');

/
--- feature 8
EXECUTE write_comment(102,402,date '2022-11-23',91,'very nice and delicious');
EXECUTE write_comment(109,402,date '2022-11-23',91,'very nice and delicious');
EXECUTE write_comment(102,411,date '2022-11-23',91,'very nice and delicious');

/

--- feature 9
EXECUTE print_all_reviews(411);
EXECUTE print_all_reviews(402);

/

--- feature 10
EXECUTE feature10(106,403,501);
EXECUTE feature10(102,406,501);
-- restaurant closed
EXECUTE feature10(102,402,501);
-- increases dish quantity for existing cart
EXECUTE feature10(101,401,501);
-- creates new cart and add dish
EXECUTE feature10(102,401,501);
/

--- feature 11

DECLARE
del_fee NUMBER;
ord_amt NUMBER;
tax_amt NUMBER;
tot_amt NUMBER;
BEGIN 
feature11(700, 1, timestamp'2022-10-13 11:05:00.00', del_fee, ord_amt, tax_amt, tot_amt);
END;

DECLARE
del_fee NUMBER;
ord_amt NUMBER;
tax_amt NUMBER;
tot_amt NUMBER;
BEGIN 
feature11(701, 1, timestamp'2022-10-13 11:05:00.00', del_fee, ord_amt, tax_amt, tot_amt);
END;
/
--- feature 12

EXECUTE generating_order(710,timestamp '2022-10-13 10:05:00.00', 1, timestamp '2022-10-13 11:15:00.00', 2, 'debit card');
EXECUTE generating_order(701,timestamp '2022-10-13 10:05:00.00', 1, timestamp '2022-10-13 11:15:00.00', 2, 'debit card');
/

--- feature 13

EXECUTE feature13(106, 1, 5, cat_array('seafood'));
EXECUTE feature13(105, 3, 15, cat_array('seafood','fast food'));
/

--- feature 14
--- invalid customer
EXECUTE feature14(116);
EXECUTE feature14(103);
/
