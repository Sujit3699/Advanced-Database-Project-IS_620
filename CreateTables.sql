-- Drop Tables
drop table customer cascade constraints;
drop table discount cascade constraints;
drop table tax cascade constraints;
drop table available_discount cascade constraints;
drop table categories cascade constraints;
drop table restaurants cascade constraints;
drop table mcategories cascade constraints; 
drop table cart cascade constraints;
drop table dish cascade constraints;
drop table cart_dish cascade constraints;
drop table reviews cascade constraints;
drop table orders cascade constraints;
drop table order_dishes cascade constraints;
drop table payment_record cascade constraints;
drop table message cascade constraints;

drop sequence "CUSTID_SEQ";
CREATE SEQUENCE custid_seq START WITH 101 INCREMENT BY 1;

drop sequence "RID_SEQ";
CREATE SEQUENCE rid_seq START WITH 401 INCREMENT BY 1;

drop sequence "DID_SEQ";
CREATE SEQUENCE did_seq START WITH 501 INCREMENT BY 1;

drop sequence "REVID_SEQ";
CREATE SEQUENCE revid_seq START WITH 601 INCREMENT BY 1;

drop sequence "CID_SEQ";
CREATE SEQUENCE cid_seq START WITH 701 INCREMENT BY 1;

drop sequence "ORDID_SEQ";
CREATE SEQUENCE ordid_seq START WITH 801 INCREMENT BY 1;

drop sequence "PAYID_SEQ";
CREATE SEQUENCE payid_seq START WITH 901 INCREMENT BY 1;

drop sequence "MSGID_SEQ";
CREATE SEQUENCE msgid_seq START WITH 1001 INCREMENT BY 1;


create table customer(
customerID NUMBER DEFAULT custid_seq.nextval NOT NULL PRIMARY KEY,
names varchar(25),
address varchar(25),
zipcode number,
state varchar(20),
email varchar(50),
credit number);

insert into customer
values(custid_seq.nextval,'Stark','209 Maiden Choice Lane',21222,'Maryland','tonystark@gmail.com',28);
insert into customer
values (custid_seq.nextval, 'Rogers', '289 Mayson Choice Avenue', 21228, 'New York', 'steverogers78@gmail.com', 89);
insert into customer
values (custid_seq.nextval, 'Banner', '246 Symington Lane', 21237, 'Maryland', 'bannerbruce345@gmail.com', 9);
insert into customer
values (custid_seq.nextval, 'Natasha', '655 Fredrick Avenue', 21237, 'Chicago', 'natasharomanoff@gmail.com', 4);
insert into customer
values (custid_seq.nextval, 'Clint', '829 Taylor Lane', 21232, 'Texas', 'clintbarton89@gmail.com', 28);

create table discount(
discountID int,
discount_description varchar(100),
discount_type int,
discount_amount float,
primary key(discountID));


insert into discount
values (201, 'Coupon', 2, 0.05);
insert into discount
values (202, 'Coupon', 2, 0.1);
insert into discount
values (203, 'FreeDel', 1, 0);
insert into discount
values (204, 'FreeDel', 1, 0);
insert into discount
values (205, 'FixedAmt', 3, 5);

create table available_discount(
--availablediscID int,
customerID int,
discountID int,
start_date date,
end_date date,
primary key(discountID),
--primary key(customerID),
--primary key(availablediscID),
foreign key(customerID) references customer,
foreign key(discountID) references discount);

insert into available_discount
values(101,201,date'2019-12-1',date '2025-1-1');
insert into available_discount 
values(102,202,date '2013-5-1',date '2013-6-3');
insert into available_discount 
values(103,203,date '2015-1-8',date '2015-2-10');
insert into available_discount 
values(104,204,date '2016-1-1',date '2016-1-31');
insert into available_discount 
values(105,205,date '2018-7-7',date '2023-12-31');

create table tax(
state varchar(30),
taxrate number,
primary key(state));

insert into tax 
values('MD', 2.67);
insert into tax 
values ('BF', 2.5);
insert into tax 
values('CD', 3.5);
insert into tax 
values('TX', 4.5);
insert into tax 
values('WA', 5);

create table restaurants(
restaurantID int,
restaurant_name varchar(50),
address varchar(200),
phone_number number,
current_status varchar(100),
zip_code number,
state varchar(30),
average_wait_time number,
average_review_score float,
primary key(restaurantID),
foreign key(state) references tax);

insert into restaurants 
values (401,'Starbucks','1000 Hilltop Circle',4434357899,'open',21226,'MD',5,7);
insert into restaurants
values (402,'Paradise','605 Fredrick Road',6685547894,'closed',21223,'TX',10,8.1);
insert into restaurants 
values (403,'Chick-fil-A','899 Arundel Avenue',6634512345,'open',21226,'MD',8,6.3);
insert into restaurants
values (404,'Subway','255 Maiden Choice Lane',4325678899,'closed',21233,'TX',15,4.8);
insert into restaurants
values (405,'Dunkins','219 Baltimore National Pike',4437896547,'open',21237,'WA',3,9.1);


create table categories(
categoryID int,
categoryname varchar(50),
restaurantID int,
primary key(categoryID),
foreign key(restaurantID) references restaurants);

insert into categories 
values(301,'fast food',401);
insert into categories 
values(302,'pizza',402);
insert into categories 
values(303,'burger',403);
insert into categories 
values(304,'asian',404);
insert into categories 
values(305,'seafood',405);

create table mcategories (
mcategoryID int,
restaurantID int,
category varchar(300),
primary key(mcategoryID),
foreign key(restaurantID) references restaurants);

insert into mcategories
values(11,401,'both italian and pizza');
Insert into mcategories
values(22,402,'both burger and asian');
insert into mcategories
values(33,403,'both asian and seafood');
insert into mcategories
values (44,404,'both seafood and pizza');
insert into mcategories
values(55,405,'both mexican and fastfood');

create table cart(
cartID NUMBER DEFAULT cid_seq.nextval NOT NULL PRIMARY KEY,
customerID int,
restaurantID int,
foreign key (customerID) references customer,
foreign key (restaurantID) references restaurants);

insert into cart 
values(cid_seq.nextval,101,401);
insert into cart 
values(cid_seq.nextval,102,402);
insert into cart 
values(cid_seq.nextval,103,403);
insert into cart 
values(cid_seq.nextval,104,404);
insert into cart 
values(cid_seq.nextval,105,405);

create table cart_dish(
cartID int,
dish_quantity int,
dishID int,
primary key(cartID, dishID),
foreign key(cartID) references cart);

insert into cart_dish 
values(701, 21,501);
insert into cart_dish 
values(702, 1, 502);
insert into cart_dish 
values(703, 3,503);
insert into cart_dish 
values(704, 4,504);
insert into cart_dish 
values(705, 5,505);

create table dish(
dishID int,
restaurantID int,
dish_name varchar(50),
price float,
primary key(dishID),
foreign key(restaurantID) references restaurants);

insert into dish 
values(501,401,'Chicken',100.1);
insert into dish 
values(502,402,'Mutton',100.2);
insert into dish 
values(503,403,'Biryani',100.3);
insert into dish 
values(504,404,'Rice',100.4);
insert into dish 
values(505,405,'Chapathi',100.5);

create table reviews (
reviewID INT DEFAULT revid_seq.nextval NOT NULL PRIMARY KEY,
customerID int,
restaurantID int,
review_date date,
review_score int,
comments varchar(300),
foreign key(customerID) references customer,
foreign key(restaurantID) references restaurants);

insert into reviews 
values(revid_seq.nextval,101,401,date '2022-10-1',90,'Delicious and we probably gonna visit soon');
insert into reviews 
values(revid_seq.nextval,102,402,date '2022-12-23',91,'Great food, great staff');
insert into reviews 
values(revid_seq.nextval,103,403,date '2022-11-19',92,'Good Indian food');
insert into reviews 
values(revid_seq.nextval,104,404,date '2022-9-11',93,'Biryani is the star of the Restaurant');
insert into reviews 
values(revid_seq.nextval,105,405,date '2022-3-17',94,'Worth a try');

create table orders(
orderID INT DEFAULT ordid_seq.nextval NOT NULL PRIMARY KEY,
restaurantID int,
customerID int,
order_time timestamp,
delivery_time timestamp,
estimated_time timestamp,
status varchar2(50),
payment_status varchar2(50),
total_cost float,
prices float,
delivery_fee float,
tip float,
taxrate float,
delivery int,
--foreign key (price) reference dish,
--foreign key(taxrate) references tax,
foreign key(restaurantID) references restaurants,
foreign key(customerID) references customer);

insert into orders
values(ordid_seq.nextval,401,101,timestamp '2022-10-13 10:05:00.00',timestamp '2022-10-13 11:05:00.00',
        timestamp '2022-10-13 11:15:00.00','Delivered','Paid',20.1,100.1,37,2,1.5,1);
insert into orders
values(ordid_seq.nextval,402,102,timestamp '2022-11-14 11:23:00.00',null,
        timestamp '2022-11-14 12:56:00.00','In progress','Paid',23.2,100.2,34,8,2.5,2);
insert into orders 
values(ordid_seq.nextval,403,103,timestamp '2022-9-21 08:35:50.40',null,
        timestamp '2022-9-21 09:18:37.00','In progress','Unpaid',65.3,100.3,31,2,3.5,2);
insert into orders 
values(ordid_seq.nextval,404,104,timestamp '2022-4-11 1:05:57.10',timestamp '2022-4-11 2:47:58.00',
        timestamp '2022-4-11 02:59:00.10','Delivered','Paid',78.14,100.4,6.77,32,4.5,2);
insert into orders 
values(ordid_seq.nextval,405,105,timestamp '2022-3-7 09:25:56.00',timestamp '2022-3-7 09:43:47.50',
        timestamp '2022-3-7 09:55:49.00','Delivered','Unpaid',27.15,100.5,6.87,13.4,5.5,1);
insert into orders 
values(ordid_seq.nextval,402,105,timestamp '2022-3-7 09:25:56.00',timestamp '2022-3-7 09:43:47.50',
        timestamp '2022-3-7 09:55:49.00','Delivered','Unpaid',27.15,100.5,6.87,13.4,5.5,1);
insert into orders 
values(ordid_seq.nextval,403,101,timestamp '2022-3-7 09:25:56.00',timestamp '2022-3-7 09:43:47.50',
        timestamp '2022-3-7 09:55:49.00','Delivered','Unpaid',27.15,100.5,6.87,13.4,5.5,1);


create table order_dishes(
orderID int,
dishID int,
dish_quantity int,
primary key(orderID),
foreign key(orderID) references orders,
foreign key(dishID) references dish);

insert into 
order_dishes values(801,501, 1);
insert into 
order_dishes values(802,502, 2);
insert into 
order_dishes values(803,503, 3);
insert into 
order_dishes values(804,504, 4);
insert into 
order_dishes values(805,505, 5);

create table payment_record (
paymentID INT DEFAULT payid_seq.nextval NOT NULL PRIMARY KEY,
customerID int,
payment_time timestamp,
orderID int,
payment_amount float,
payment_method varchar(100),
foreign key(customerID) references customer,
foreign key(orderID) references orders);

insert into payment_record 
values(payid_seq.nextval,101,timestamp '2022-6-19 12:05:05.00',801,20.1,'Debit card');
insert into payment_record 
values(payid_seq.nextval,102,timestamp '2022-7-21 10:45:00.00',802,23.2,'Credit card'); 
insert into payment_record 
values(payid_seq.nextval,103,timestamp '2022-8-13 09:07:00.00',803,65.3,'Zelle'); 
insert into payment_record 
values(payid_seq.nextval,104,timestamp '2022-9-23 07:06:00.00',804,78.14,'Credit card'); 
insert into payment_record 
values(payid_seq.nextval,105,timestamp '2022-2-28 01:43:00.00',805, 27.15,'Paypal');   

create table message(
messageID INT DEFAULT msgid_seq.nextval NOT NULL PRIMARY KEY,
customerID int,
message_time timestamp,
message_body varchar(500),
foreign key(customerID) references customer);

insert into message 
values(msgid_seq.nextval,101,timestamp '2022-10-14 10:05:00.00','Paneer Butter Masala is exceptional');
insert into message 
values(msgid_seq.nextval,102,timestamp '2022-8-18 12:55:08.50','Rotis could have been better');
insert into message 
values(msgid_seq.nextval,103,timestamp '2022-9-21 08:47:19.13','I have had the best food in the recent times at your restaurant');
insert into message 
values(msgid_seq.nextval,104,timestamp '2022-12-31 06:57:40.17','Keep up the good work!');
insert into message 
values(msgid_seq.nextval,105,timestamp '2022-2-19 11:56:50.34','Would love to visit again'); 

