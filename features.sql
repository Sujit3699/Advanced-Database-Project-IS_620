SET SERVEROUTPUT ON;
set autoprint on;

-- feature 1
CREATE OR REPLACE PROCEDURE add_customer(ns varchar, addr varchar, zip number,
st varchar, em varchar, cred number)
AS

r_count NUMBER;
cust_id NUMBER;

BEGIN

SELECT count(*) INTO r_count
FROM customer
WHERE email = em;

IF r_count = 0 THEN

cust_id := custid_seq.nextval;

insert into customer values(cust_id, ns, addr,
zip, st, em, cred);

COMMIT;

dbms_output.put_line('Record Inserted. CustomerID : '|| cust_id);

ELSE
-- print & update
dbms_output.put_line('the client already exists');
UPDATE customer
SET address = addr,
zipcode = zip,
state = st
WHERE email = em;

END IF;

END;
/



--- feature 2

CREATE OR REPLACE PROCEDURE check_email(em varchar)
AS
r_count NUMBER;
p_cid NUMBER;
p_n VARCHAR(256);
p_add VARCHAR(256);
p_zip NUMBER;
p_st VARCHAR(256);
p_em VARCHAR(256);
p_cr NUMBER;
p_del NUMBER;
p_cost NUMBER;
BEGIN

SELECT count(*) INTO r_count
FROM customer
WHERE email = em;

IF r_count = 0 THEN
dbms_output.put_line('No Such Customer');


ELSE
-- print customer details
select cu.customerid, names, address, zipcode, state, email, credit,
        count(ord.orderid), sum(total_cost)
        INTO p_cid, p_n, p_add, p_zip, p_st, p_em, p_cr, p_del, p_cost
        from customer cu
        left join orders ord
        on cu.customerid = ord.customerid
        where email=em and TRUNC(order_time) >= sysdate - 180 and ord.status = 'Delivered'
        GROUP BY cu.customerid, names, address, zipcode, state, email, credit;
        
        dbms_output.put_line(p_cid || ' | ' || p_n || ' | ' || p_add || ' | '
        || p_zip || ' | ' || p_st || ' | '
        || p_em || ' | ' || p_cr || ' | '|| p_del || ' | '|| p_cost);
END IF;

END;
/


--- feature 3

CREATE OR REPLACE PROCEDURE check_restaurant_by_category(cat varchar)
AS
p_w NUMBER;
p_n VARCHAR(256);
p_add NUMBER;
p_zip NUMBER;
BEGIN

select restaurant_name, average_review_score, average_wait_time, zip_code
INTO p_n, p_add, p_w, p_zip
from restaurants rs
left join categories ca
on rs.restaurantid = ca.restaurantid
where ca.categoryname LIKE '%'||cat||'%' and rs.current_status = 'open';

dbms_output.put_line(p_n || ' | ' || p_add || ' | ' || p_w || ' | ' || p_zip);

END;
/



--- feature 4

CREATE OR REPLACE PROCEDURE check_id(rid number)
AS
r_count NUMBER;
p_n VARCHAR(256);
p_cr NUMBER;
BEGIN

SELECT count(*) INTO r_count
FROM dish
WHERE restaurantid = rid;

IF r_count = 0 THEN
dbms_output.put_line('No Such Restaurant');


ELSE
-- print customer details
select dish_name, price
INTO p_n, p_cr
from dish ds
where ds.restaurantid = rid;
dbms_output.put_line(p_n || ' | ' || p_cr);
END IF;

END;
/



--- feature 5

CREATE OR REPLACE PROCEDURE check_cartid(rid number)
AS
r_count NUMBER;
p_n VARCHAR(256);
p_cr NUMBER;
p_dq NUMBER;

BEGIN

SELECT count(*) INTO r_count
FROM cart
WHERE cartid = rid;

IF r_count = 0 THEN
dbms_output.put_line('Invalid Cart Id');


ELSE
-- print customer details
select dish_name, price, dish_quantity
INTO p_n, p_cr, p_dq
from cart cs
left join cart_dish ds
on cs.cartid = ds.cartid
right join dish dd
on dd.dishid = ds.dishid
where cs.cartid = rid;

dbms_output.put_line(p_n || ' | ' || p_cr || ' | ' || p_dq);

END IF;

END;
/

--- feature 6

CREATE OR REPLACE PROCEDURE check_quantity(cid number , did number)
AS
r_count NUMBER;
d_count NUMBER;

BEGIN

SELECT count(*) INTO r_count
FROM cart
WHERE cartid = cid;

IF r_count = 0 THEN
dbms_output.put_line('Invalid Cart Id');


ELSE
select dish_quantity into d_count
from cart_dish ds
where ds.cartid = cid and ds.dishid = did;
END IF;


IF d_count = 1 THEN

DELETE FROM cart_dish
WHERE cartid = cid and dishid = did;

dbms_output.put_line('dish removed');


ELSE
UPDATE cart_dish
SET dish_quantity = d_count - 1
where cartid = cid and dishid = did;

dbms_output.put_line('dish quantity reduced');

END IF;

END;
/



--- feature 7


CREATE OR REPLACE PROCEDURE update_status(ordid number , ost number, tst timestamp)
AS
r_count NUMBER;
cid NUMBER;
orc NUMBER;
ostatus varchar(256);
pmet varchar(256);


BEGIN

SELECT count(*) INTO r_count
FROM orders
WHERE orderid = ordid;

IF r_count = 0 THEN
dbms_output.put_line('invalid order id');


ELSE
SELECT customerid, status, total_cost INTO cid, ostatus, orc
FROM orders WHERE orderid = ordid;

IF ost = 2 THEN

UPDATE orders
SET status = 'Delivered'
WHERE orderid = ordid;

insert into message values(msgid_seq.nextval, cid, tst,
'your order has been delivered.');


ELSIF ost = 3 then
UPDATE orders
SET status = 'Cancelled'
WHERE orderid = ordid;

insert into payment_record values(payid_seq.nextval, cid, tst,
ordid, -orc, 'Credit Card');


insert into message values(msgid_seq.nextval, cid, tst,
'your order has been cacelled and Refund is issued.');

ELSE
dbms_output.put_line('order status must be either 2 or 3');


END IF;

END IF;

END;
/


-- feature 8

CREATE OR REPLACE PROCEDURE write_comment(cid number , rid number , rdt date, rsc number, rvc varchar)
AS
c_count NUMBER;
r_count NUMBER;
avg_rs NUMBER;

BEGIN

SELECT count(*) INTO c_count
FROM customer
WHERE customerid = cid;

SELECT count(*) INTO r_count
FROM restaurants
WHERE restaurantid = rid;

IF c_count = 0 THEN
    dbms_output.put_line('invalid customer id');

ELSIF r_count = 0 then
    dbms_output.put_line('invalid restaurant id');

ELSE
    insert into reviews values(revid_seq.nextval, cid, rid, rdt, rsc, rvc);
    
    select avg(review_score) into avg_rs 
    from reviews
    where restaurantid = rid
    group by restaurantid;
    
    UPDATE restaurants
    SET average_review_score = avg_rs
    WHERE restaurantid = rid;

    END IF;

END;
/


--- feature 9
CREATE OR REPLACE PROCEDURE print_all_reviews(rid number)
AS
rc sys_refcursor;
c_count NUMBER;
r_count NUMBER;
avg_rs NUMBER;

BEGIN

SELECT count(*) INTO r_count
FROM restaurants
WHERE restaurantid = rid;

IF r_count = 0 THEN
    dbms_output.put_line('invalid restaurant id');

ELSE
    open rc for select * from reviews where restaurantid = rid;
    dbms_sql.return_result(rc);

    END IF;

END;
/

------------------ START OF GROUP FEATURES ------------------

--- feature 10

--SET SERVEROUTPUT ON;
--set autoprint on;

CREATE OR REPLACE PROCEDURE feature10(cid number , rid number , did number)
AS
c_count NUMBER;
r_count NUMBER;
rd_count NUMBER;
cr_count NUMBER;
ccr_count NUMBER;
crd_count NUMBER;
cust_cartid NUMBER;
dsq NUMBER;
res_stat varchar(64);

BEGIN

SELECT count(*) INTO c_count
FROM customer
WHERE customerid = cid;

SELECT count(*) INTO r_count
FROM restaurants r
WHERE r.restaurantid = rid;

SELECT count(*) INTO rd_count
FROM restaurants r
inner join dish d
on r.restaurantid = d.restaurantid
WHERE r.restaurantid = rid and d.dishid=did;

SELECT count(*) INTO cr_count
FROM cart
WHERE customerid = cid and restaurantid = rid;


IF c_count = 0 THEN
    dbms_output.put_line('invalid customer id');

ELSIF r_count = 0 then
    dbms_output.put_line('invalid restaurant id');
    
ELSE
    select current_status into res_stat
    from restaurants
    where restaurantid = rid;
    
    select count(*) into ccr_count
    from cart 
    where customerid=cid and restaurantid=rid;
    
    select count(*) into crd_count
    from cart c
    inner join cart_dish d
    on c.cartid = d.cartid
    where customerid=cid and restaurantid=rid;
    
    dbms_output.put_line(crd_count);
    
    IF res_stat = 'closed' then
        dbms_output.put_line('Restaurant Closed');
    ELSIF rd_count = 0 then
        dbms_output.put_line('invalid dish id');   
    ELSIF crd_count > 0 then
    
        select cartid into cust_cartid
        from cart 
        where customerid=cid and restaurantid=rid;
        dbms_output.put_line(cust_cartid);
        
        select dish_quantity into dsq
        from cart c
        left join cart_dish cd
        on c.cartid = cd.cartid
        where customerid=cid and restaurantid=rid and dishid = did
        and c.cartid = cust_cartid;
    
        UPDATE cart_dish
        SET dish_quantity = dsq + 1
        where cartid = cust_cartid and dishid = did;
        dbms_output.put_line('Increase dish quantity');
        
    ELSIF ccr_count > 0 then
        dbms_output.put_line('Add dish to cart_dish');
        select cartid into cust_cartid
        from cart where customerid=cid and restaurantid=rid;
        insert into cart_dish values(cust_cartid, 1, did);

    ELSE
        cust_cartid := cid_seq.nextval;
        dbms_output.put_line('Added dish to New Cart created with Id: '|| cust_cartid);   
        insert into cart values(cust_cartid, cid, rid);
        insert into cart_dish values(cust_cartid, 1, did);    

    END IF;
    
END IF;

END;
/



--- feature 11

CREATE OR REPLACE PROCEDURE feature11(carid number , ddm number , cct timestamp, 
                        del_fee OUT NUMBER, ord_amt OUT NUMBER, tax_amt OUT NUMBER, tot_amt OUT NUMBER)
AS
c_count NUMBER;
r_count NUMBER;
cart_price NUMBER;
czip NUMBER;
rzip NUMBER;
rtax NUMBER;

distyp varchar(64);
disper NUMBER;

dis_amt NUMBER;

BEGIN

SELECT count(*) INTO c_count
FROM cart
WHERE cartid = carid;

IF c_count = 0 THEN
    dbms_output.put_line('invalid customer id');

ELSIF r_count = 0 then
    dbms_output.put_line('invalid restaurant id');

ELSE
        select SUM(cd.dish_quantity * d.price) into cart_price
        from cart c
        inner join cart_dish cd
        on c.cartid = cd.cartid
        inner join dish d
        on c.restaurantid = d.restaurantid
        and cd.dishid = d.dishid
        where c.cartid = carid
        group by c.cartid;
        
        dbms_output.put_line(cart_price);
        
        
        select cd.zipcode, r.zip_code, d.discount_type, d.discount_amount, t.taxrate
        into czip, rzip, distyp, disper, rtax
        from cart c
        inner join customer cd
        on c.customerid = cd.customerid
        inner join restaurants r
        on c.restaurantid = r.restaurantid
        left join available_discount ad
        on ad.customerid = c.customerid
        inner join discount d
        on d.discountid = ad.discountid
        inner join tax t
        on t.state = r.state
        where c.cartid = carid
        and ad.start_date <= trunc(cct) and ad.end_date >= trunc(cct);
                
        IF czip <> rzip 
            then del_fee := 5;
        ELSE 
            del_fee := 2;
        END IF;
        
        IF ddm = 2 
            then del_fee := 0;
        END IF;

        IF distyp = 1 
            then del_fee := 0;
            dis_amt := 0;
        ELSIF distyp = 2 then
            dis_amt := cart_price * disper;
        ELSE 
            dis_amt := disper;
        END IF;
        
    ord_amt := cart_price - dis_amt;
    tax_amt := ord_amt * rtax * 0.01;
    tot_amt :=  ord_amt + del_fee + tax_amt;
    
    dbms_output.put_line(ord_amt || ' | '  ||tax_amt || ' | ' ||tot_amt);
    
    END IF;

END;
/

--- feature 12

CREATE OR REPLACE PROCEDURE generating_order(carid number , ordtime timestamp, 
                                    ddm number, estime timestamp, tip number, paym varchar)
AS
c_count NUMBER;
del_fee NUMBER;
ord_amt NUMBER;
tax_amt NUMBER;
tot_amt NUMBER;
new_orid NUMBER;
cusid NUMBER;
resid NUMBER;
msg_str varchar(512);

BEGIN

SELECT count(*) INTO c_count
FROM cart
WHERE cartid = carid;


IF c_count = 0 THEN
    dbms_output.put_line('invalid cart id');
    
ELSE

    select customerid, restaurantid
    into cusid, resid
    from cart
    where cartid = carid;
    
    feature11(carid, ddm, ordtime, del_fee, ord_amt, tax_amt, tot_amt);
    
    new_orid := ordid_seq.nextval;
    
    insert into orders 
    values(new_orid, resid, cusid, ordtime, null, estime, 'In progress', 'Paid', 
            tot_amt, ord_amt, del_fee, tip, tax_amt, ddm);
        
        
    INSERT INTO order_dishes
    select new_orid, dishid, dish_quantity
    from cart_dish
    where cartid=carid;
    
    delete from cart_dish 
    where cartid = carid;
    
    delete from cart
    where cartid = carid;    
    
    msg_str := 'A new order ' ||  new_orid || ' is placed at Restaurant ' ||  resid || ' with estimated time of ' || to_char(estime-ordtime, 'MI') || ' and amount '|| tot_amt;
    insert into message values(msgid_seq.nextval, cusid, ordtime, msg_str);
    
    insert into payment_record values(payid_seq.nextval, cusid, ordtime,
                        new_orid, tot_amt, paym);
                        
    dbms_output.put_line('complete. Details inserted into Orders, Message and Payment Tables.');

    END IF;

END;
/

--- feature 13

CREATE OR REPLACE TYPE cat_array AS TABLE OF VARCHAR2(20);
/
CREATE OR REPLACE PROCEDURE feature13(cid number , mrs number ,  wt number, cats cat_array)
AS
rc sys_refcursor;
c_count NUMBER;
czc NUMBER;
d_count NUMBER;
rcs varchar(256);

BEGIN

SELECT count(*) INTO c_count
FROM customer
WHERE customerid = cid;

IF c_count = 0 THEN
    dbms_output.put_line('invalid customer id');
    
ELSE

    SELECT zipcode INTO czc
    FROM customer
    WHERE customerid = cid;
    -- dbms_output.put_line(czc);
        
    open rc for select restaurant_name, categoryname, current_status, 
    average_wait_time, average_review_score, 
    zip_code, address
    FROM restaurants r left join categories c on r.restaurantid = c.restaurantid
    WHERE average_review_score >= mrs
    and categoryname in (select * from table( cats ))
    and average_wait_time <= wt
    and substr(r.zip_code,1,4) = substr(czc,1,4);

    dbms_sql.return_result(rc);
    END IF;
    
END;
/


-- feature 14

CREATE OR REPLACE PROCEDURE feature14(cid number)
AS
rc sys_refcursor;
c_count NUMBER;
cust_rest NUMBER;
custs NUMBER;
rec_rest NUMBER;

BEGIN

SELECT count(*) INTO c_count
FROM customer
WHERE customerid = cid;

IF c_count = 0 THEN
    dbms_output.put_line('invalid customer id');
    
ELSE

    SELECT restaurantid into cust_rest
    FROM orders
    WHERE customerid = cid;
    
    SELECT distinct customerid into custs
    FROM orders
    WHERE restaurantid in cust_rest and customerid != cid ;
    dbms_output.put_line('Similar Customer Ids: '||custs);
    
    SELECT distinct restaurantid into rec_rest
    FROM orders
    WHERE customerid in custs and restaurantid not in cust_rest;
        
    open rc for SELECT *
    FROM restaurants
    WHERE restaurantid in rec_rest;
    dbms_sql.return_result(rc);

    END IF;

END;
/




