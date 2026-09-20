-- ============================================================
-- RETAILMART CLASSROOM DATABASE
-- PostgreSQL setup for Filtering & Sorting practice
-- Based on the tables/columns used in the provided RetailMart PPT.
-- This is a SMALL classroom dataset, not the original RetailMart DB.
-- ============================================================

-- ------------------------------------------------------------
-- 1. CREATE SCHEMAS
-- ------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS customers;
CREATE SCHEMA IF NOT EXISTS products;
CREATE SCHEMA IF NOT EXISTS sales;
CREATE SCHEMA IF NOT EXISTS stores;
CREATE SCHEMA IF NOT EXISTS support;
CREATE SCHEMA IF NOT EXISTS web_events;

-- ------------------------------------------------------------
-- 2. CREATE TABLES
-- ------------------------------------------------------------

DROP TABLE IF EXISTS web_events.page_views;
DROP TABLE IF EXISTS support.tickets;
DROP TABLE IF EXISTS sales.shipments;
DROP TABLE IF EXISTS sales.orders;
DROP TABLE IF EXISTS stores.employees;
DROP TABLE IF EXISTS stores.stores;
DROP TABLE IF EXISTS products.products;
DROP TABLE IF EXISTS customers.customers;

CREATE TABLE customers.customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    registration_date DATE,
    tier VARCHAR(20)
);

CREATE TABLE products.products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    brand_id INT,
    supplier_id INT,
    price NUMERIC(10,2),
    cost_price NUMERIC(10,2)
);

CREATE TABLE stores.stores (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    region_id INT,
    city VARCHAR(50),
    square_ft INT,
    opening_date DATE
);

CREATE TABLE stores.employees (
    employee_id SERIAL PRIMARY KEY,
    store_id INT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    role VARCHAR(50),
    dept_id INT,
    joining_date DATE,
    salary NUMERIC(12,2)
);

CREATE TABLE sales.orders (
    order_id SERIAL PRIMARY KEY,
    cust_id INT,
    store_id INT,
    order_date TIMESTAMP,
    order_status VARCHAR(30),
    gross_total NUMERIC(12,2),
    discount_amount NUMERIC(12,2),
    net_total NUMERIC(12,2),
    payment_mode_id INT
);

CREATE TABLE sales.shipments (
    shipment_id SERIAL PRIMARY KEY,
    order_id INT,
    courier_name VARCHAR(50),
    shipped_date TIMESTAMP,
    delivered_date TIMESTAMP
);

CREATE TABLE support.tickets (
    ticket_id SERIAL PRIMARY KEY,
    customer_id INT,
    agent_id INT,
    category VARCHAR(50),
    priority VARCHAR(20),
    status VARCHAR(20),
    created_date TIMESTAMP,
    resolved_date TIMESTAMP,
    subject VARCHAR(200)
);

CREATE TABLE web_events.page_views (
    page_view_id SERIAL PRIMARY KEY,
    customer_id INT,
    page_url VARCHAR(200),
    viewed_at TIMESTAMP
);

-- ------------------------------------------------------------
-- 3. INSERT CUSTOMERS
-- Includes different tiers, cities, Gmail addresses and NULLs.
-- ------------------------------------------------------------

INSERT INTO customers.customers
(first_name, last_name, email, phone, registration_date, tier)
VALUES
('Aarav','Sharma','aarav.sharma@gmail.com','9876500011','2025-01-05','Gold'),
('Priya','Verma','priya.verma@gmail.com','9876500012','2025-01-12','Silver'),
('Rohan','Mehta','rohan.mehta@yahoo.com','9876500013','2025-02-10','Gold'),
('Ananya','Singh','ananya.singh@gmail.com','9876500014','2025-02-18','Platinum'),
('Vikas','Kumar','vikas.kumar@GMAIL.COM','9876500015','2025-03-02','Bronze'),
('Sneha','Gupta','sneha.gupta@gmail.com','9876500016','2025-03-14','Gold'),
('Aditya','Joshi','aditya.joshi@outlook.com','9876500017','2025-04-01','Silver'),
('Simran','Kaur','simran.kaur@gmail.com','9876500018','2025-04-17','Gold'),
('Aman','Malhotra','aman.malhotra@yahoo.com','9876500019','2025-05-09','Bronze'),
('Sakshi','Mishra',NULL,'9876500020','2025-05-20','Silver'),
('Pranav','Agarwal','pranav.agarwal@gmail.com',NULL,'2025-06-03','Platinum'),
('Neha','Bansal','neha.bansal@gmail.com','9876500022','2025-06-18','Gold'),
('Arjun','Rao','arjun.rao@outlook.com','9876500023','2025-07-04','Silver'),
('Shreya','Kapoor','shreya.kapoor@gmail.com','9876500024','2025-07-22','Gold'),
('Rahul','Yadav','rahul.yadav@yahoo.com','9876500025','2025-08-11','Bronze'),
('Isha','Sharma','isha.sharma@gmail.com','9876500026','2025-08-25','Gold'),
('Karan','Sethi','karan.sethi@outlook.com','9876500027','2025-09-06','Silver'),
('Pooja','Nair','pooja.nair@gmail.com','9876500028','2025-09-19','Platinum'),
('Saurabh','Jain','saurabh.jain@gmail.com','9876500029','2025-10-03','Gold'),
('Divya','Chopra','divya.chopra@yahoo.com','9876500030','2025-10-18','Silver');

-- ------------------------------------------------------------
-- 4. INSERT PRODUCTS
-- Prices intentionally cover <100, BETWEEN, >500 and high values.
-- ------------------------------------------------------------

INSERT INTO products.products
(product_name, brand_id, supplier_id, price, cost_price)
VALUES
('Wireless Mouse',101,201,799.00,450.00),
('Mechanical Keyboard',102,202,3499.00,2200.00),
('USB-C Cable',103,203,499.00,220.00),
('Laptop Stand',104,204,1299.00,750.00),
('Bluetooth Speaker',105,205,2499.00,1500.00),
('Smart Watch',106,206,5999.00,3800.00),
('Gaming Headset',107,207,3999.00,2400.00),
('27 Inch Monitor',108,208,18999.00,13000.00),
('Office Chair',109,209,12999.00,8500.00),
('Laptop',110,210,65999.00,52000.00),
('Premium Laptop',111,211,89999.00,71000.00),
('Phone Case',112,212,299.00,120.00),
('HDMI Cable',113,213,699.00,350.00),
('Power Bank',114,214,1499.00,900.00),
('Tablet',115,215,32999.00,25000.00);

-- ------------------------------------------------------------
-- 5. INSERT STORES
-- ------------------------------------------------------------

INSERT INTO stores.stores
(store_name, region_id, city, square_ft, opening_date)
VALUES
('RetailMart Delhi Central',1,'Delhi',4500,'2021-01-15'),
('RetailMart Gurgaon',1,'Gurgaon',3200,'2021-05-20'),
('RetailMart Noida',1,'Noida',2800,'2022-02-10'),
('RetailMart Mumbai Central',2,'Mumbai',5200,'2020-08-12'),
('RetailMart Pune',2,'Pune',3500,'2022-06-18'),
('RetailMart Bangalore',3,'Bangalore',4100,'2021-11-25'),
('RetailMart Hyderabad',3,'Hyderabad',2900,'2023-01-05'),
('RetailMart Chennai',3,'Chennai',3800,'2022-09-14'),
('RetailMart Jaipur',4,'Jaipur',2400,'2023-04-22'),
('RetailMart Chandigarh',4,'Chandigarh',3300,'2023-08-16');

-- ------------------------------------------------------------
-- 6. INSERT EMPLOYEES
-- ------------------------------------------------------------

INSERT INTO stores.employees
(store_id, first_name, last_name, email, role, dept_id, joining_date, salary)
VALUES
(1,'Ravi','Sharma','ravi.sharma@retailmart.com','Manager',10,'2021-02-01',65000),
(1,'Neeraj','Kumar','neeraj.kumar@retailmart.com','Sales Executive',20,'2022-04-15',32000),
(2,'Meena','Gupta','meena.gupta@retailmart.com','Manager',10,'2021-06-01',68000),
(2,'Amit','Verma','amit.verma@retailmart.com','Sales Executive',20,'2023-01-10',30000),
(3,'Pankaj','Singh','pankaj.singh@retailmart.com','Sales Executive',20,'2022-03-12',34000),
(4,'Kavita','Rao','kavita.rao@retailmart.com','Manager',10,'2020-09-01',72000),
(5,'Nitin','Joshi','nitin.joshi@retailmart.com','Support Executive',30,'2022-07-20',36000),
(6,'Ankit','Mehta','ankit.mehta@retailmart.com','Manager',10,'2022-01-15',70000),
(7,'Komal','Yadav','komal.yadav@retailmart.com','Sales Executive',20,'2023-02-10',31000),
(8,'Sonal','Nair','sonal.nair@retailmart.com','HR Executive',40,'2022-10-01',42000),
(9,'Deepak','Jain','deepak.jain@retailmart.com','Sales Executive',20,'2023-05-05',29500),
(10,'Ritu','Kapoor','ritu.kapoor@retailmart.com','Manager',10,'2023-09-01',62000),
(1,'Varun','Bansal','varun.bansal@retailmart.com','Sales Executive',20,'2024-01-10',33500),
(4,'Isha','Malhotra','isha.malhotra@retailmart.com','Support Executive',30,'2023-11-20',38000),
(6,'Mohit','Agarwal',NULL,'Sales Executive',20,'2024-03-01',32500);

-- ------------------------------------------------------------
-- 7. INSERT ORDERS
-- Includes different statuses, dates, totals and NULLs.
-- ------------------------------------------------------------

INSERT INTO sales.orders
(cust_id, store_id, order_date, order_status, gross_total, discount_amount, net_total, payment_mode_id)
VALUES
(1,1,'2025-01-05 10:30:00','Delivered',5500.00,500.00,5000.00,1),
(2,2,'2025-01-18 14:20:00','Delivered',2500.00,0.00,2500.00,2),
(3,3,'2025-02-02 16:45:00','Cancelled',3499.00,0.00,3499.00,1),
(4,4,'2025-02-14 11:15:00','Delivered',65999.00,5000.00,60999.00,3),
(5,5,'2025-03-08 18:10:00','Processing',12999.00,1000.00,11999.00,2),
(6,6,'2025-03-21 12:05:00','Delivered',5999.00,500.00,5499.00,1),
(7,7,'2025-04-10 15:30:00','Out for Delivery',18999.00,2000.00,16999.00,3),
(8,8,'2025-04-22 09:45:00','Delivered',1499.00,0.00,1499.00,2),
(9,9,'2025-05-06 17:25:00','Pending',89999.00,9000.00,80999.00,3),
(10,10,'2025-05-19 13:40:00','Delivered',799.00,0.00,799.00,1),
(11,1,'2025-06-02 10:00:00','Processing',32999.00,3000.00,29999.00,2),
(12,2,'2025-06-15 19:15:00','Delivered',3999.00,500.00,3499.00,1),
(13,3,'2025-07-01 11:50:00','Cancelled',1299.00,0.00,1299.00,2),
(14,4,'2025-07-18 16:00:00','Delivered',2499.00,200.00,2299.00,1),
(15,5,'2025-08-05 14:35:00','Processing',699.00,0.00,699.00,2),
(16,6,'2025-08-22 10:25:00','Delivered',18999.00,1500.00,17499.00,3),
(17,7,'2025-09-03 12:15:00','Out for Delivery',1499.00,100.00,1399.00,1),
(18,8,'2025-09-17 17:40:00','Delivered',32999.00,3000.00,29999.00,3),
(19,9,'2025-10-04 09:20:00','Pending',499.00,0.00,499.00,2),
(20,10,'2025-10-20 15:05:00','Delivered',9999.00,1000.00,8999.00,1),
(1,1,CURRENT_TIMESTAMP - INTERVAL '45 days','Processing',7599.00,500.00,7099.00,2),
(2,2,CURRENT_TIMESTAMP - INTERVAL '5 days','Processing',2499.00,200.00,2299.00,1);

-- ------------------------------------------------------------
-- 8. INSERT SHIPMENTS
-- NULL delivered_date = shipment not yet delivered.
-- ------------------------------------------------------------

INSERT INTO sales.shipments
(order_id, courier_name, shipped_date, delivered_date)
VALUES
(1,'BlueDart','2025-01-06 09:00:00','2025-01-07 16:00:00'),
(2,'Delhivery','2025-01-19 10:30:00','2025-01-21 14:00:00'),
(4,'FedEx','2025-02-15 08:00:00','2025-02-18 18:30:00'),
(5,'BlueDart','2025-03-09 11:00:00',NULL),
(6,'Delhivery','2025-03-22 09:30:00','2025-03-24 13:20:00'),
(7,'Ecom Express','2025-04-11 12:00:00',NULL),
(8,'BlueDart','2025-04-23 10:00:00','2025-04-25 15:10:00'),
(9,'FedEx','2025-05-07 09:00:00',NULL),
(10,'Delhivery','2025-05-20 11:00:00','2025-05-21 17:00:00'),
(11,'BlueDart','2025-06-03 10:15:00',NULL),
(12,'Ecom Express','2025-06-16 08:45:00','2025-06-18 12:30:00'),
(14,'FedEx','2025-07-19 13:00:00','2025-07-21 16:45:00');

-- ------------------------------------------------------------
-- 9. INSERT SUPPORT TICKETS
-- Includes open tickets, priorities and NULL resolved dates.
-- ------------------------------------------------------------

INSERT INTO support.tickets
(customer_id, agent_id, category, priority, status, created_date, resolved_date, subject)
VALUES
(1,101,'Payment','High','Open','2025-01-06 10:00:00',NULL,'Payment failed'),
(2,102,'Delivery','Medium','Resolved','2025-01-20 11:30:00','2025-01-21 14:00:00','Delivery status'),
(3,103,'Product','Low','Resolved','2025-02-03 15:00:00','2025-02-04 10:00:00','Product information'),
(4,101,'Refund','High','Open','2025-02-20 09:00:00',NULL,'Refund request'),
(5,104,'Delivery','High','Open','2025-03-10 12:00:00',NULL,'Delayed shipment'),
(6,105,'Account','Medium','Resolved','2025-03-23 16:00:00','2025-03-24 11:00:00','Account update'),
(7,102,'Product','Low','Open','2025-04-12 13:00:00',NULL,'Product damaged'),
(8,103,'Payment','High','Resolved','2025-04-24 09:30:00','2025-04-25 13:00:00','Payment issue'),
(9,104,'Delivery','Medium','Open','2025-05-08 17:00:00',NULL,'Order not delivered'),
(10,105,'Account','Low','Resolved','2025-05-21 10:00:00','2025-05-22 12:00:00','Change phone number'),
(11,101,'Refund','High','Open',CURRENT_TIMESTAMP - INTERVAL '10 days',NULL,'Refund pending'),
(12,102,'Delivery','Medium','Open',CURRENT_TIMESTAMP - INTERVAL '3 days',NULL,'Delivery update');

-- ------------------------------------------------------------
-- 10. INSERT PAGE VIEWS
-- Includes NULL customer_id for IS NULL practice.
-- ------------------------------------------------------------

INSERT INTO web_events.page_views
(customer_id, page_url, viewed_at)
VALUES
(1,'/home','2025-01-05 09:00:00'),
(1,'/products/laptop','2025-01-05 09:10:00'),
(2,'/home','2025-01-18 13:00:00'),
(3,'/products/keyboard','2025-02-02 15:30:00'),
(4,'/products/laptop','2025-02-14 10:30:00'),
(5,'/cart','2025-03-08 17:30:00'),
(6,'/products/smart-watch','2025-03-21 11:00:00'),
(NULL,'/home','2025-04-01 08:00:00'),
(8,'/products/power-bank','2025-04-22 08:30:00'),
(9,'/checkout','2025-05-06 16:45:00'),
(10,'/home','2025-05-19 12:50:00'),
(NULL,'/products/monitor','2025-06-01 10:00:00'),
(12,'/products/headset','2025-06-15 18:00:00'),
(14,'/products/speaker','2025-07-18 15:30:00'),
(16,'/home','2025-08-22 09:45:00');

-- ============================================================
-- 11. QUICK CHECKS
-- Run these after the setup.
-- ============================================================

SELECT * FROM customers.customers;
SELECT * FROM products.products;
SELECT * FROM stores.stores;
SELECT * FROM stores.employees;
SELECT * FROM sales.orders;
SELECT * FROM sales.shipments;
SELECT * FROM support.tickets;
SELECT * FROM web_events.page_views;

