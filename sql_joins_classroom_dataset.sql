-- SQL JOIN CLASSROOM DATASET
-- PostgreSQL
-- 60 rows in EVERY table
-- Designed for INNER / LEFT / RIGHT / FULL OUTER JOIN practice

DROP SCHEMA IF EXISTS sales CASCADE;
DROP SCHEMA IF EXISTS customers CASCADE;
DROP SCHEMA IF EXISTS products CASCADE;
DROP SCHEMA IF EXISTS stores CASCADE;
DROP SCHEMA IF EXISTS core CASCADE;

CREATE SCHEMA customers;
CREATE SCHEMA sales;
CREATE SCHEMA products;
CREATE SCHEMA stores;
CREATE SCHEMA core;

-- =========================
-- 1. TABLE DEFINITIONS
-- =========================

CREATE TABLE customers.customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    state VARCHAR(50),
    email VARCHAR(120)
);

CREATE TABLE stores.stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    state VARCHAR(50)
);

CREATE TABLE stores.employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    store_id INT NOT NULL REFERENCES stores.stores(store_id),
    job_title VARCHAR(50),
    salary INT
);

CREATE TABLE core.dim_brand (
    brand_id INT PRIMARY KEY,
    brand_name VARCHAR(100) NOT NULL,
    country VARCHAR(50)
);

CREATE TABLE products.products (
    prod_id INT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(50),
    brand_id INT NOT NULL REFERENCES core.dim_brand(brand_id),
    price NUMERIC(10,2)
);

CREATE TABLE sales.orders (
    order_id INT PRIMARY KEY,
    cust_id INT NOT NULL REFERENCES customers.customers(customer_id),
    store_id INT NOT NULL REFERENCES stores.stores(store_id),
    order_date DATE NOT NULL,
    order_status VARCHAR(30),
    total_amount NUMERIC(12,2)
);

CREATE TABLE sales.order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL REFERENCES sales.orders(order_id),
    prod_id INT NOT NULL REFERENCES products.products(prod_id),
    quantity INT NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL
);

CREATE TABLE sales.payments (
    payment_id INT PRIMARY KEY,
    order_id INT NOT NULL REFERENCES sales.orders(order_id),
    payment_date DATE NOT NULL,
    payment_method VARCHAR(30),
    payment_status VARCHAR(30),
    amount NUMERIC(12,2)
);

CREATE TABLE sales.shipments (
    shipment_id INT PRIMARY KEY,
    order_id INT NOT NULL REFERENCES sales.orders(order_id),
    shipment_date DATE,
    delivery_date DATE,
    carrier VARCHAR(50),
    shipment_status VARCHAR(30)
);


INSERT INTO core.dim_brand VALUES (1, 'Apple', 'USA');
INSERT INTO core.dim_brand VALUES (2, 'Samsung', 'South Korea');
INSERT INTO core.dim_brand VALUES (3, 'Dell', 'USA');
INSERT INTO core.dim_brand VALUES (4, 'HP', 'USA');
INSERT INTO core.dim_brand VALUES (5, 'Lenovo', 'China');
INSERT INTO core.dim_brand VALUES (6, 'Sony', 'Japan');
INSERT INTO core.dim_brand VALUES (7, 'OnePlus', 'China');
INSERT INTO core.dim_brand VALUES (8, 'Xiaomi', 'China');
INSERT INTO core.dim_brand VALUES (9, 'LG', 'South Korea');
INSERT INTO core.dim_brand VALUES (10, 'Asus', 'Taiwan');
INSERT INTO core.dim_brand VALUES (11, 'Acer', 'USA');
INSERT INTO core.dim_brand VALUES (12, 'Boat', 'South Korea');
INSERT INTO core.dim_brand VALUES (13, 'JBL', 'USA');
INSERT INTO core.dim_brand VALUES (14, 'Canon', 'USA');
INSERT INTO core.dim_brand VALUES (15, 'Nikon', 'China');
INSERT INTO core.dim_brand VALUES (16, 'Logitech', 'Japan');
INSERT INTO core.dim_brand VALUES (17, 'Microsoft', 'China');
INSERT INTO core.dim_brand VALUES (18, 'Google', 'China');
INSERT INTO core.dim_brand VALUES (19, 'Realme', 'South Korea');
INSERT INTO core.dim_brand VALUES (20, 'Vivo', 'Taiwan');
INSERT INTO core.dim_brand VALUES (21, 'Apple 21', 'USA');
INSERT INTO core.dim_brand VALUES (22, 'Samsung 22', 'South Korea');
INSERT INTO core.dim_brand VALUES (23, 'Dell 23', 'USA');
INSERT INTO core.dim_brand VALUES (24, 'HP 24', 'USA');
INSERT INTO core.dim_brand VALUES (25, 'Lenovo 25', 'China');
INSERT INTO core.dim_brand VALUES (26, 'Sony 26', 'Japan');
INSERT INTO core.dim_brand VALUES (27, 'OnePlus 27', 'China');
INSERT INTO core.dim_brand VALUES (28, 'Xiaomi 28', 'China');
INSERT INTO core.dim_brand VALUES (29, 'LG 29', 'South Korea');
INSERT INTO core.dim_brand VALUES (30, 'Asus 30', 'Taiwan');
INSERT INTO core.dim_brand VALUES (31, 'Acer 31', 'USA');
INSERT INTO core.dim_brand VALUES (32, 'Boat 32', 'South Korea');
INSERT INTO core.dim_brand VALUES (33, 'JBL 33', 'USA');
INSERT INTO core.dim_brand VALUES (34, 'Canon 34', 'USA');
INSERT INTO core.dim_brand VALUES (35, 'Nikon 35', 'China');
INSERT INTO core.dim_brand VALUES (36, 'Logitech 36', 'Japan');
INSERT INTO core.dim_brand VALUES (37, 'Microsoft 37', 'China');
INSERT INTO core.dim_brand VALUES (38, 'Google 38', 'China');
INSERT INTO core.dim_brand VALUES (39, 'Realme 39', 'South Korea');
INSERT INTO core.dim_brand VALUES (40, 'Vivo 40', 'Taiwan');
INSERT INTO core.dim_brand VALUES (41, 'Apple 41', 'USA');
INSERT INTO core.dim_brand VALUES (42, 'Samsung 42', 'South Korea');
INSERT INTO core.dim_brand VALUES (43, 'Dell 43', 'USA');
INSERT INTO core.dim_brand VALUES (44, 'HP 44', 'USA');
INSERT INTO core.dim_brand VALUES (45, 'Lenovo 45', 'China');
INSERT INTO core.dim_brand VALUES (46, 'Sony 46', 'Japan');
INSERT INTO core.dim_brand VALUES (47, 'OnePlus 47', 'China');
INSERT INTO core.dim_brand VALUES (48, 'Xiaomi 48', 'China');
INSERT INTO core.dim_brand VALUES (49, 'LG 49', 'South Korea');
INSERT INTO core.dim_brand VALUES (50, 'Asus 50', 'Taiwan');
INSERT INTO core.dim_brand VALUES (51, 'Acer 51', 'USA');
INSERT INTO core.dim_brand VALUES (52, 'Boat 52', 'South Korea');
INSERT INTO core.dim_brand VALUES (53, 'JBL 53', 'USA');
INSERT INTO core.dim_brand VALUES (54, 'Canon 54', 'USA');
INSERT INTO core.dim_brand VALUES (55, 'Nikon 55', 'China');
INSERT INTO core.dim_brand VALUES (56, 'Logitech 56', 'Japan');
INSERT INTO core.dim_brand VALUES (57, 'Microsoft 57', 'China');
INSERT INTO core.dim_brand VALUES (58, 'Google 58', 'China');
INSERT INTO core.dim_brand VALUES (59, 'Realme 59', 'South Korea');
INSERT INTO core.dim_brand VALUES (60, 'Vivo 60', 'Taiwan');

INSERT INTO stores.stores VALUES (1, 'TechMart Delhi 1', 'Delhi', 'Delhi');
INSERT INTO stores.stores VALUES (2, 'TechMart Noida 2', 'Noida', 'Uttar Pradesh');
INSERT INTO stores.stores VALUES (3, 'TechMart Gurgaon 3', 'Gurgaon', 'Haryana');
INSERT INTO stores.stores VALUES (4, 'TechMart Jaipur 4', 'Jaipur', 'Rajasthan');
INSERT INTO stores.stores VALUES (5, 'TechMart Lucknow 5', 'Lucknow', 'Uttar Pradesh');
INSERT INTO stores.stores VALUES (6, 'TechMart Pune 6', 'Pune', 'Maharashtra');
INSERT INTO stores.stores VALUES (7, 'TechMart Mumbai 7', 'Mumbai', 'Maharashtra');
INSERT INTO stores.stores VALUES (8, 'TechMart Bengaluru 8', 'Bengaluru', 'Karnataka');
INSERT INTO stores.stores VALUES (9, 'TechMart Chandigarh 9', 'Chandigarh', 'Chandigarh');
INSERT INTO stores.stores VALUES (10, 'TechMart Hyderabad 10', 'Hyderabad', 'Telangana');
INSERT INTO stores.stores VALUES (11, 'TechMart Delhi 11', 'Delhi', 'Delhi');
INSERT INTO stores.stores VALUES (12, 'TechMart Noida 12', 'Noida', 'Uttar Pradesh');
INSERT INTO stores.stores VALUES (13, 'TechMart Gurgaon 13', 'Gurgaon', 'Haryana');
INSERT INTO stores.stores VALUES (14, 'TechMart Jaipur 14', 'Jaipur', 'Rajasthan');
INSERT INTO stores.stores VALUES (15, 'TechMart Lucknow 15', 'Lucknow', 'Uttar Pradesh');
INSERT INTO stores.stores VALUES (16, 'TechMart Pune 16', 'Pune', 'Maharashtra');
INSERT INTO stores.stores VALUES (17, 'TechMart Mumbai 17', 'Mumbai', 'Maharashtra');
INSERT INTO stores.stores VALUES (18, 'TechMart Bengaluru 18', 'Bengaluru', 'Karnataka');
INSERT INTO stores.stores VALUES (19, 'TechMart Chandigarh 19', 'Chandigarh', 'Chandigarh');
INSERT INTO stores.stores VALUES (20, 'TechMart Hyderabad 20', 'Hyderabad', 'Telangana');
INSERT INTO stores.stores VALUES (21, 'TechMart Delhi 21', 'Delhi', 'Delhi');
INSERT INTO stores.stores VALUES (22, 'TechMart Noida 22', 'Noida', 'Uttar Pradesh');
INSERT INTO stores.stores VALUES (23, 'TechMart Gurgaon 23', 'Gurgaon', 'Haryana');
INSERT INTO stores.stores VALUES (24, 'TechMart Jaipur 24', 'Jaipur', 'Rajasthan');
INSERT INTO stores.stores VALUES (25, 'TechMart Lucknow 25', 'Lucknow', 'Uttar Pradesh');
INSERT INTO stores.stores VALUES (26, 'TechMart Pune 26', 'Pune', 'Maharashtra');
INSERT INTO stores.stores VALUES (27, 'TechMart Mumbai 27', 'Mumbai', 'Maharashtra');
INSERT INTO stores.stores VALUES (28, 'TechMart Bengaluru 28', 'Bengaluru', 'Karnataka');
INSERT INTO stores.stores VALUES (29, 'TechMart Chandigarh 29', 'Chandigarh', 'Chandigarh');
INSERT INTO stores.stores VALUES (30, 'TechMart Hyderabad 30', 'Hyderabad', 'Telangana');
INSERT INTO stores.stores VALUES (31, 'TechMart Delhi 31', 'Delhi', 'Delhi');
INSERT INTO stores.stores VALUES (32, 'TechMart Noida 32', 'Noida', 'Uttar Pradesh');
INSERT INTO stores.stores VALUES (33, 'TechMart Gurgaon 33', 'Gurgaon', 'Haryana');
INSERT INTO stores.stores VALUES (34, 'TechMart Jaipur 34', 'Jaipur', 'Rajasthan');
INSERT INTO stores.stores VALUES (35, 'TechMart Lucknow 35', 'Lucknow', 'Uttar Pradesh');
INSERT INTO stores.stores VALUES (36, 'TechMart Pune 36', 'Pune', 'Maharashtra');
INSERT INTO stores.stores VALUES (37, 'TechMart Mumbai 37', 'Mumbai', 'Maharashtra');
INSERT INTO stores.stores VALUES (38, 'TechMart Bengaluru 38', 'Bengaluru', 'Karnataka');
INSERT INTO stores.stores VALUES (39, 'TechMart Chandigarh 39', 'Chandigarh', 'Chandigarh');
INSERT INTO stores.stores VALUES (40, 'TechMart Hyderabad 40', 'Hyderabad', 'Telangana');
INSERT INTO stores.stores VALUES (41, 'TechMart Delhi 41', 'Delhi', 'Delhi');
INSERT INTO stores.stores VALUES (42, 'TechMart Noida 42', 'Noida', 'Uttar Pradesh');
INSERT INTO stores.stores VALUES (43, 'TechMart Gurgaon 43', 'Gurgaon', 'Haryana');
INSERT INTO stores.stores VALUES (44, 'TechMart Jaipur 44', 'Jaipur', 'Rajasthan');
INSERT INTO stores.stores VALUES (45, 'TechMart Lucknow 45', 'Lucknow', 'Uttar Pradesh');
INSERT INTO stores.stores VALUES (46, 'TechMart Pune 46', 'Pune', 'Maharashtra');
INSERT INTO stores.stores VALUES (47, 'TechMart Mumbai 47', 'Mumbai', 'Maharashtra');
INSERT INTO stores.stores VALUES (48, 'TechMart Bengaluru 48', 'Bengaluru', 'Karnataka');
INSERT INTO stores.stores VALUES (49, 'TechMart Chandigarh 49', 'Chandigarh', 'Chandigarh');
INSERT INTO stores.stores VALUES (50, 'TechMart Hyderabad 50', 'Hyderabad', 'Telangana');
INSERT INTO stores.stores VALUES (51, 'TechMart Delhi 51', 'Delhi', 'Delhi');
INSERT INTO stores.stores VALUES (52, 'TechMart Noida 52', 'Noida', 'Uttar Pradesh');
INSERT INTO stores.stores VALUES (53, 'TechMart Gurgaon 53', 'Gurgaon', 'Haryana');
INSERT INTO stores.stores VALUES (54, 'TechMart Jaipur 54', 'Jaipur', 'Rajasthan');
INSERT INTO stores.stores VALUES (55, 'TechMart Lucknow 55', 'Lucknow', 'Uttar Pradesh');
INSERT INTO stores.stores VALUES (56, 'TechMart Pune 56', 'Pune', 'Maharashtra');
INSERT INTO stores.stores VALUES (57, 'TechMart Mumbai 57', 'Mumbai', 'Maharashtra');
INSERT INTO stores.stores VALUES (58, 'TechMart Bengaluru 58', 'Bengaluru', 'Karnataka');
INSERT INTO stores.stores VALUES (59, 'TechMart Chandigarh 59', 'Chandigarh', 'Chandigarh');
INSERT INTO stores.stores VALUES (60, 'TechMart Hyderabad 60', 'Hyderabad', 'Telangana');

INSERT INTO customers.customers VALUES (1, 'Ankit 1', 'Delhi', 'Delhi', 'ankit1@example.com');
INSERT INTO customers.customers VALUES (2, 'Rahul 2', 'Noida', 'Uttar Pradesh', 'rahul2@example.com');
INSERT INTO customers.customers VALUES (3, 'Priya 3', 'Gurgaon', 'Haryana', 'priya3@example.com');
INSERT INTO customers.customers VALUES (4, 'Aman 4', 'Jaipur', 'Rajasthan', 'aman4@example.com');
INSERT INTO customers.customers VALUES (5, 'Neha 5', 'Lucknow', 'Uttar Pradesh', 'neha5@example.com');
INSERT INTO customers.customers VALUES (6, 'Rohit 6', 'Pune', 'Maharashtra', 'rohit6@example.com');
INSERT INTO customers.customers VALUES (7, 'Sneha 7', 'Mumbai', 'Maharashtra', 'sneha7@example.com');
INSERT INTO customers.customers VALUES (8, 'Vikas 8', 'Bengaluru', 'Karnataka', 'vikas8@example.com');
INSERT INTO customers.customers VALUES (9, 'Pooja 9', 'Chandigarh', 'Chandigarh', 'pooja9@example.com');
INSERT INTO customers.customers VALUES (10, 'Arjun 10', 'Hyderabad', 'Telangana', 'arjun10@example.com');
INSERT INTO customers.customers VALUES (11, 'Karan 11', 'Delhi', 'Delhi', 'karan11@example.com');
INSERT INTO customers.customers VALUES (12, 'Simran 12', 'Noida', 'Uttar Pradesh', 'simran12@example.com');
INSERT INTO customers.customers VALUES (13, 'Aditya 13', 'Gurgaon', 'Haryana', 'aditya13@example.com');
INSERT INTO customers.customers VALUES (14, 'Nisha 14', 'Jaipur', 'Rajasthan', 'nisha14@example.com');
INSERT INTO customers.customers VALUES (15, 'Varun 15', 'Lucknow', 'Uttar Pradesh', 'varun15@example.com');
INSERT INTO customers.customers VALUES (16, 'Kavya 16', 'Pune', 'Maharashtra', 'kavya16@example.com');
INSERT INTO customers.customers VALUES (17, 'Manish 17', 'Mumbai', 'Maharashtra', 'manish17@example.com');
INSERT INTO customers.customers VALUES (18, 'Riya 18', 'Bengaluru', 'Karnataka', 'riya18@example.com');
INSERT INTO customers.customers VALUES (19, 'Saurabh 19', 'Chandigarh', 'Chandigarh', 'saurabh19@example.com');
INSERT INTO customers.customers VALUES (20, 'Isha 20', 'Hyderabad', 'Telangana', 'isha20@example.com');
INSERT INTO customers.customers VALUES (21, 'Mohit 21', 'Delhi', 'Delhi', 'mohit21@example.com');
INSERT INTO customers.customers VALUES (22, 'Shreya 22', 'Noida', 'Uttar Pradesh', 'shreya22@example.com');
INSERT INTO customers.customers VALUES (23, 'Nitin 23', 'Gurgaon', 'Haryana', 'nitin23@example.com');
INSERT INTO customers.customers VALUES (24, 'Anjali 24', 'Jaipur', 'Rajasthan', 'anjali24@example.com');
INSERT INTO customers.customers VALUES (25, 'Deepak 25', 'Lucknow', 'Uttar Pradesh', 'deepak25@example.com');
INSERT INTO customers.customers VALUES (26, 'Meera 26', 'Pune', 'Maharashtra', 'meera26@example.com');
INSERT INTO customers.customers VALUES (27, 'Abhishek 27', 'Mumbai', 'Maharashtra', 'abhishek27@example.com');
INSERT INTO customers.customers VALUES (28, 'Tanya 28', 'Bengaluru', 'Karnataka', 'tanya28@example.com');
INSERT INTO customers.customers VALUES (29, 'Yash 29', 'Chandigarh', 'Chandigarh', 'yash29@example.com');
INSERT INTO customers.customers VALUES (30, 'Aditi 30', 'Hyderabad', 'Telangana', 'aditi30@example.com');
INSERT INTO customers.customers VALUES (31, 'Ravi 31', 'Delhi', 'Delhi', 'ravi31@example.com');
INSERT INTO customers.customers VALUES (32, 'Sakshi 32', 'Noida', 'Uttar Pradesh', 'sakshi32@example.com');
INSERT INTO customers.customers VALUES (33, 'Harsh 33', 'Gurgaon', 'Haryana', 'harsh33@example.com');
INSERT INTO customers.customers VALUES (34, 'Muskan 34', 'Jaipur', 'Rajasthan', 'muskan34@example.com');
INSERT INTO customers.customers VALUES (35, 'Akash 35', 'Lucknow', 'Uttar Pradesh', 'akash35@example.com');
INSERT INTO customers.customers VALUES (36, 'Divya 36', 'Pune', 'Maharashtra', 'divya36@example.com');
INSERT INTO customers.customers VALUES (37, 'Gaurav 37', 'Mumbai', 'Maharashtra', 'gaurav37@example.com');
INSERT INTO customers.customers VALUES (38, 'Komal 38', 'Bengaluru', 'Karnataka', 'komal38@example.com');
INSERT INTO customers.customers VALUES (39, 'Ayush 39', 'Chandigarh', 'Chandigarh', 'ayush39@example.com');
INSERT INTO customers.customers VALUES (40, 'Preeti 40', 'Hyderabad', 'Telangana', 'preeti40@example.com');
INSERT INTO customers.customers VALUES (41, 'Vivek 41', 'Delhi', 'Delhi', 'vivek41@example.com');
INSERT INTO customers.customers VALUES (42, 'Swati 42', 'Noida', 'Uttar Pradesh', 'swati42@example.com');
INSERT INTO customers.customers VALUES (43, 'Rakesh 43', 'Gurgaon', 'Haryana', 'rakesh43@example.com');
INSERT INTO customers.customers VALUES (44, 'Pallavi 44', 'Jaipur', 'Rajasthan', 'pallavi44@example.com');
INSERT INTO customers.customers VALUES (45, 'Sumit 45', 'Lucknow', 'Uttar Pradesh', 'sumit45@example.com');
INSERT INTO customers.customers VALUES (46, 'Tanvi 46', 'Pune', 'Maharashtra', 'tanvi46@example.com');
INSERT INTO customers.customers VALUES (47, 'Rajat 47', 'Mumbai', 'Maharashtra', 'rajat47@example.com');
INSERT INTO customers.customers VALUES (48, 'Mansi 48', 'Bengaluru', 'Karnataka', 'mansi48@example.com');
INSERT INTO customers.customers VALUES (49, 'Aakash 49', 'Chandigarh', 'Chandigarh', 'aakash49@example.com');
INSERT INTO customers.customers VALUES (50, 'Kirti 50', 'Hyderabad', 'Telangana', 'kirti50@example.com');
INSERT INTO customers.customers VALUES (51, 'Aarav 51', 'Delhi', 'Delhi', 'aarav51@example.com');
INSERT INTO customers.customers VALUES (52, 'Ananya 52', 'Noida', 'Uttar Pradesh', 'ananya52@example.com');
INSERT INTO customers.customers VALUES (53, 'Dev 53', 'Gurgaon', 'Haryana', 'dev53@example.com');
INSERT INTO customers.customers VALUES (54, 'Ishita 54', 'Jaipur', 'Rajasthan', 'ishita54@example.com');
INSERT INTO customers.customers VALUES (55, 'Kabir 55', 'Lucknow', 'Uttar Pradesh', 'kabir55@example.com');
INSERT INTO customers.customers VALUES (56, 'Navya 56', 'Pune', 'Maharashtra', 'navya56@example.com');
INSERT INTO customers.customers VALUES (57, 'Rohan 57', 'Mumbai', 'Maharashtra', 'rohan57@example.com');
INSERT INTO customers.customers VALUES (58, 'Sanya 58', 'Bengaluru', 'Karnataka', 'sanya58@example.com');
INSERT INTO customers.customers VALUES (59, 'Varun 59', 'Chandigarh', 'Chandigarh', 'varun59@example.com');
INSERT INTO customers.customers VALUES (60, 'Zoya 60', 'Hyderabad', 'Telangana', 'zoya60@example.com');

INSERT INTO stores.employees VALUES (1, 'Manish 1', 1, 'Sales Executive', 28000);
INSERT INTO stores.employees VALUES (2, 'Riya 2', 2, 'Store Manager', 30500);
INSERT INTO stores.employees VALUES (3, 'Saurabh 3', 3, 'Cashier', 33000);
INSERT INTO stores.employees VALUES (4, 'Isha 4', 4, 'Support Executive', 35500);
INSERT INTO stores.employees VALUES (5, 'Mohit 5', 5, 'Inventory Associate', 38000);
INSERT INTO stores.employees VALUES (6, 'Shreya 6', 6, 'Sales Executive', 40500);
INSERT INTO stores.employees VALUES (7, 'Nitin 7', 7, 'Store Manager', 43000);
INSERT INTO stores.employees VALUES (8, 'Anjali 8', 8, 'Cashier', 45500);
INSERT INTO stores.employees VALUES (9, 'Deepak 9', 9, 'Support Executive', 48000);
INSERT INTO stores.employees VALUES (10, 'Meera 10', 10, 'Inventory Associate', 50500);
INSERT INTO stores.employees VALUES (11, 'Abhishek 11', 11, 'Sales Executive', 28000);
INSERT INTO stores.employees VALUES (12, 'Tanya 12', 12, 'Store Manager', 30500);
INSERT INTO stores.employees VALUES (13, 'Yash 13', 13, 'Cashier', 33000);
INSERT INTO stores.employees VALUES (14, 'Aditi 14', 14, 'Support Executive', 35500);
INSERT INTO stores.employees VALUES (15, 'Ravi 15', 15, 'Inventory Associate', 38000);
INSERT INTO stores.employees VALUES (16, 'Sakshi 16', 16, 'Sales Executive', 40500);
INSERT INTO stores.employees VALUES (17, 'Harsh 17', 17, 'Store Manager', 43000);
INSERT INTO stores.employees VALUES (18, 'Muskan 18', 18, 'Cashier', 45500);
INSERT INTO stores.employees VALUES (19, 'Akash 19', 19, 'Support Executive', 48000);
INSERT INTO stores.employees VALUES (20, 'Divya 20', 20, 'Inventory Associate', 50500);
INSERT INTO stores.employees VALUES (21, 'Gaurav 21', 21, 'Sales Executive', 28000);
INSERT INTO stores.employees VALUES (22, 'Komal 22', 22, 'Store Manager', 30500);
INSERT INTO stores.employees VALUES (23, 'Ayush 23', 23, 'Cashier', 33000);
INSERT INTO stores.employees VALUES (24, 'Preeti 24', 24, 'Support Executive', 35500);
INSERT INTO stores.employees VALUES (25, 'Vivek 25', 25, 'Inventory Associate', 38000);
INSERT INTO stores.employees VALUES (26, 'Swati 26', 26, 'Sales Executive', 40500);
INSERT INTO stores.employees VALUES (27, 'Rakesh 27', 27, 'Store Manager', 43000);
INSERT INTO stores.employees VALUES (28, 'Pallavi 28', 28, 'Cashier', 45500);
INSERT INTO stores.employees VALUES (29, 'Sumit 29', 29, 'Support Executive', 48000);
INSERT INTO stores.employees VALUES (30, 'Tanvi 30', 30, 'Inventory Associate', 50500);
INSERT INTO stores.employees VALUES (31, 'Rajat 31', 31, 'Sales Executive', 28000);
INSERT INTO stores.employees VALUES (32, 'Mansi 32', 32, 'Store Manager', 30500);
INSERT INTO stores.employees VALUES (33, 'Aakash 33', 33, 'Cashier', 33000);
INSERT INTO stores.employees VALUES (34, 'Kirti 34', 34, 'Support Executive', 35500);
INSERT INTO stores.employees VALUES (35, 'Aarav 35', 35, 'Inventory Associate', 38000);
INSERT INTO stores.employees VALUES (36, 'Ananya 36', 36, 'Sales Executive', 40500);
INSERT INTO stores.employees VALUES (37, 'Dev 37', 37, 'Store Manager', 43000);
INSERT INTO stores.employees VALUES (38, 'Ishita 38', 38, 'Cashier', 45500);
INSERT INTO stores.employees VALUES (39, 'Kabir 39', 39, 'Support Executive', 48000);
INSERT INTO stores.employees VALUES (40, 'Navya 40', 40, 'Inventory Associate', 50500);
INSERT INTO stores.employees VALUES (41, 'Rohan 41', 41, 'Sales Executive', 28000);
INSERT INTO stores.employees VALUES (42, 'Sanya 42', 42, 'Store Manager', 30500);
INSERT INTO stores.employees VALUES (43, 'Varun 43', 43, 'Cashier', 33000);
INSERT INTO stores.employees VALUES (44, 'Zoya 44', 44, 'Support Executive', 35500);
INSERT INTO stores.employees VALUES (45, 'Ankit 45', 45, 'Inventory Associate', 38000);
INSERT INTO stores.employees VALUES (46, 'Rahul 46', 46, 'Sales Executive', 40500);
INSERT INTO stores.employees VALUES (47, 'Priya 47', 47, 'Store Manager', 43000);
INSERT INTO stores.employees VALUES (48, 'Aman 48', 48, 'Cashier', 45500);
INSERT INTO stores.employees VALUES (49, 'Neha 49', 49, 'Support Executive', 48000);
INSERT INTO stores.employees VALUES (50, 'Rohit 50', 50, 'Inventory Associate', 50500);
INSERT INTO stores.employees VALUES (51, 'Sneha 51', 51, 'Sales Executive', 28000);
INSERT INTO stores.employees VALUES (52, 'Vikas 52', 52, 'Store Manager', 30500);
INSERT INTO stores.employees VALUES (53, 'Pooja 53', 53, 'Cashier', 33000);
INSERT INTO stores.employees VALUES (54, 'Arjun 54', 54, 'Support Executive', 35500);
INSERT INTO stores.employees VALUES (55, 'Karan 55', 55, 'Inventory Associate', 38000);
INSERT INTO stores.employees VALUES (56, 'Simran 56', 56, 'Sales Executive', 40500);
INSERT INTO stores.employees VALUES (57, 'Aditya 57', 57, 'Store Manager', 43000);
INSERT INTO stores.employees VALUES (58, 'Nisha 58', 58, 'Cashier', 45500);
INSERT INTO stores.employees VALUES (59, 'Varun 59', 59, 'Support Executive', 48000);
INSERT INTO stores.employees VALUES (60, 'Kavya 60', 60, 'Inventory Associate', 50500);

INSERT INTO products.products VALUES (1, 'MacBook Air M3 1', 'Laptop', 1, 99999);
INSERT INTO products.products VALUES (2, 'Galaxy S24 2', 'Mobile', 2, 74999);
INSERT INTO products.products VALUES (3, 'Dell Inspiron 15 3', 'Laptop', 3, 58999);
INSERT INTO products.products VALUES (4, 'HP Pavilion 14 4', 'Laptop', 4, 64999);
INSERT INTO products.products VALUES (5, 'Lenovo IdeaPad 3 5', 'Laptop', 5, 47999);
INSERT INTO products.products VALUES (6, 'Sony WH-1000XM5 6', 'Headphones', 6, 29999);
INSERT INTO products.products VALUES (7, 'OnePlus 12 7', 'Mobile', 7, 64999);
INSERT INTO products.products VALUES (8, 'Redmi Note 14 8', 'Mobile', 8, 24999);
INSERT INTO products.products VALUES (9, 'LG UltraGear 27 9', 'Monitor', 9, 28999);
INSERT INTO products.products VALUES (10, 'Asus Vivobook 15 10', 'Laptop', 10, 55999);
INSERT INTO products.products VALUES (11, 'Acer Aspire 7 11', 'Laptop', 11, 62999);
INSERT INTO products.products VALUES (12, 'Boat Rockerz 550 12', 'Headphones', 12, 1999);
INSERT INTO products.products VALUES (13, 'JBL Tune 770NC 13', 'Headphones', 13, 5999);
INSERT INTO products.products VALUES (14, 'Canon EOS 1500D 14', 'Camera', 14, 41999);
INSERT INTO products.products VALUES (15, 'Nikon D3500 15', 'Camera', 15, 45999);
INSERT INTO products.products VALUES (16, 'Logitech MX Keys 16', 'Keyboard', 16, 8999);
INSERT INTO products.products VALUES (17, 'Microsoft Surface Go 17', 'Tablet', 17, 49999);
INSERT INTO products.products VALUES (18, 'Google Pixel 9 18', 'Mobile', 18, 79999);
INSERT INTO products.products VALUES (19, 'Realme GT 6 19', 'Mobile', 19, 39999);
INSERT INTO products.products VALUES (20, 'Vivo V40 20', 'Mobile', 20, 34999);
INSERT INTO products.products VALUES (21, 'Samsung 55 OLED 21', 'TV', 21, 109999);
INSERT INTO products.products VALUES (22, 'LG 50 4K TV 22', 'TV', 22, 59999);
INSERT INTO products.products VALUES (23, 'Apple Watch Series 10 23', 'Smartwatch', 23, 46999);
INSERT INTO products.products VALUES (24, 'Galaxy Watch 7 24', 'Smartwatch', 24, 34999);
INSERT INTO products.products VALUES (25, 'Xiaomi Pad 7 25', 'Tablet', 25, 29999);
INSERT INTO products.products VALUES (26, 'OnePlus Pad 2 26', 'Tablet', 26, 39999);
INSERT INTO products.products VALUES (27, 'Dell 24 Monitor 27', 'Monitor', 27, 13999);
INSERT INTO products.products VALUES (28, 'HP 24 Monitor 28', 'Monitor', 28, 12999);
INSERT INTO products.products VALUES (29, 'Lenovo Legion 5 29', 'Laptop', 29, 89999);
INSERT INTO products.products VALUES (30, 'Asus ROG Strix 30', 'Laptop', 30, 129999);
INSERT INTO products.products VALUES (31, 'Sony Bravia 55 31', 'TV', 31, 89999);
INSERT INTO products.products VALUES (32, 'Samsung Galaxy Tab 32', 'Tablet', 32, 44999);
INSERT INTO products.products VALUES (33, 'Boat Airdopes 141 33', 'Headphones', 33, 1299);
INSERT INTO products.products VALUES (34, 'JBL Flip 6 34', 'Headphones', 34, 10999);
INSERT INTO products.products VALUES (35, 'Canon Pixma Printer 35', 'Camera', 35, 8999);
INSERT INTO products.products VALUES (36, 'Logitech G502 36', 'Mouse', 36, 6999);
INSERT INTO products.products VALUES (37, 'Microsoft Surface Mouse 37', 'Mouse', 37, 4999);
INSERT INTO products.products VALUES (38, 'Apple Magic Mouse 38', 'Mouse', 38, 7999);
INSERT INTO products.products VALUES (39, 'OnePlus Nord CE 39', 'Mobile', 39, 24999);
INSERT INTO products.products VALUES (40, 'Samsung A55 40', 'Mobile', 40, 36999);
INSERT INTO products.products VALUES (41, 'Xiaomi 14 41', 'Mobile', 41, 69999);
INSERT INTO products.products VALUES (42, 'Realme 13 Pro 42', 'Mobile', 42, 29999);
INSERT INTO products.products VALUES (43, 'Vivo T3 43', 'Mobile', 43, 21999);
INSERT INTO products.products VALUES (44, 'Acer Nitro V 44', 'Laptop', 44, 74999);
INSERT INTO products.products VALUES (45, 'HP Victus 45', 'Laptop', 45, 84999);
INSERT INTO products.products VALUES (46, 'Lenovo LOQ 46', 'Laptop', 46, 79999);
INSERT INTO products.products VALUES (47, 'Dell G15 47', 'Laptop', 47, 91999);
INSERT INTO products.products VALUES (48, 'Asus TUF Gaming 48', 'Laptop', 48, 89999);
INSERT INTO products.products VALUES (49, 'LG Ultrawide 49', 'Monitor', 49, 31999);
INSERT INTO products.products VALUES (50, 'Samsung Smart Monitor 50', 'Monitor', 50, 36999);
INSERT INTO products.products VALUES (51, 'Sony WH-CH720N 51', 'Headphones', 51, 9999);
INSERT INTO products.products VALUES (52, 'Boat Nirvana 52', 'Headphones', 52, 2499);
INSERT INTO products.products VALUES (53, 'JBL Live 660NC 53', 'Headphones', 53, 11999);
INSERT INTO products.products VALUES (54, 'Canon EOS R50 54', 'Camera', 54, 72999);
INSERT INTO products.products VALUES (55, 'Nikon Z30 55', 'Camera', 55, 65999);
INSERT INTO products.products VALUES (56, 'Google Pixel Tablet 56', 'Tablet', 56, 59999);
INSERT INTO products.products VALUES (57, 'Apple iPad Air 57', 'Tablet', 57, 69999);
INSERT INTO products.products VALUES (58, 'Samsung QLED 55 58', 'TV', 58, 94999);
INSERT INTO products.products VALUES (59, 'LG OLED 48 59', 'TV', 59, 104999);
INSERT INTO products.products VALUES (60, 'Apple Watch SE 60', 'Smartwatch', 60, 29999);

INSERT INTO sales.orders VALUES (1, 1, 1, '2026-01-05', 'Completed', 1137.00);
INSERT INTO sales.orders VALUES (2, 2, 2, '2026-01-08', 'Completed', 1274.00);
INSERT INTO sales.orders VALUES (3, 3, 3, '2026-01-11', 'Processing', 1411.00);
INSERT INTO sales.orders VALUES (4, 4, 4, '2026-01-14', 'Shipped', 1548.00);
INSERT INTO sales.orders VALUES (5, 5, 5, '2026-01-17', 'Cancelled', 1685.00);
INSERT INTO sales.orders VALUES (6, 6, 6, '2026-01-20', 'Completed', 1822.00);
INSERT INTO sales.orders VALUES (7, 7, 7, '2026-01-23', 'Completed', 1959.00);
INSERT INTO sales.orders VALUES (8, 8, 8, '2026-01-26', 'Processing', 2096.00);
INSERT INTO sales.orders VALUES (9, 9, 9, '2026-01-29', 'Shipped', 2233.00);
INSERT INTO sales.orders VALUES (10, 10, 10, '2026-02-01', 'Cancelled', 2370.00);
INSERT INTO sales.orders VALUES (11, 11, 11, '2026-02-04', 'Completed', 2507.00);
INSERT INTO sales.orders VALUES (12, 12, 12, '2026-02-07', 'Completed', 2644.00);
INSERT INTO sales.orders VALUES (13, 13, 13, '2026-02-10', 'Processing', 2781.00);
INSERT INTO sales.orders VALUES (14, 14, 14, '2026-02-13', 'Shipped', 2918.00);
INSERT INTO sales.orders VALUES (15, 15, 15, '2026-02-16', 'Cancelled', 3055.00);
INSERT INTO sales.orders VALUES (16, 16, 16, '2026-02-19', 'Completed', 3192.00);
INSERT INTO sales.orders VALUES (17, 17, 17, '2026-02-22', 'Completed', 3329.00);
INSERT INTO sales.orders VALUES (18, 18, 18, '2026-02-25', 'Processing', 3466.00);
INSERT INTO sales.orders VALUES (19, 19, 19, '2026-02-28', 'Shipped', 3603.00);
INSERT INTO sales.orders VALUES (20, 20, 20, '2026-03-03', 'Cancelled', 3740.00);
INSERT INTO sales.orders VALUES (21, 21, 21, '2026-03-06', 'Completed', 3877.00);
INSERT INTO sales.orders VALUES (22, 22, 22, '2026-03-09', 'Completed', 4014.00);
INSERT INTO sales.orders VALUES (23, 23, 23, '2026-03-12', 'Processing', 4151.00);
INSERT INTO sales.orders VALUES (24, 24, 24, '2026-03-15', 'Shipped', 4288.00);
INSERT INTO sales.orders VALUES (25, 25, 25, '2026-03-18', 'Cancelled', 4425.00);
INSERT INTO sales.orders VALUES (26, 26, 26, '2026-03-21', 'Completed', 4562.00);
INSERT INTO sales.orders VALUES (27, 27, 27, '2026-03-24', 'Completed', 4699.00);
INSERT INTO sales.orders VALUES (28, 28, 28, '2026-03-27', 'Processing', 4836.00);
INSERT INTO sales.orders VALUES (29, 29, 29, '2026-03-30', 'Shipped', 4973.00);
INSERT INTO sales.orders VALUES (30, 30, 30, '2026-04-02', 'Cancelled', 5110.00);
INSERT INTO sales.orders VALUES (31, 31, 31, '2026-04-05', 'Completed', 5247.00);
INSERT INTO sales.orders VALUES (32, 32, 32, '2026-04-08', 'Completed', 5384.00);
INSERT INTO sales.orders VALUES (33, 33, 33, '2026-04-11', 'Processing', 5521.00);
INSERT INTO sales.orders VALUES (34, 34, 34, '2026-04-14', 'Shipped', 5658.00);
INSERT INTO sales.orders VALUES (35, 35, 35, '2026-04-17', 'Cancelled', 5795.00);
INSERT INTO sales.orders VALUES (36, 36, 36, '2026-04-20', 'Completed', 5932.00);
INSERT INTO sales.orders VALUES (37, 37, 37, '2026-04-23', 'Completed', 6069.00);
INSERT INTO sales.orders VALUES (38, 38, 38, '2026-04-26', 'Processing', 6206.00);
INSERT INTO sales.orders VALUES (39, 39, 39, '2026-04-29', 'Shipped', 6343.00);
INSERT INTO sales.orders VALUES (40, 40, 40, '2026-05-02', 'Cancelled', 6480.00);
INSERT INTO sales.orders VALUES (41, 41, 41, '2026-05-05', 'Completed', 6617.00);
INSERT INTO sales.orders VALUES (42, 42, 42, '2026-05-08', 'Completed', 6754.00);
INSERT INTO sales.orders VALUES (43, 43, 43, '2026-05-11', 'Processing', 6891.00);
INSERT INTO sales.orders VALUES (44, 44, 44, '2026-05-14', 'Shipped', 7028.00);
INSERT INTO sales.orders VALUES (45, 45, 45, '2026-05-17', 'Cancelled', 7165.00);
INSERT INTO sales.orders VALUES (46, 46, 46, '2026-05-20', 'Completed', 7302.00);
INSERT INTO sales.orders VALUES (47, 47, 47, '2026-05-23', 'Completed', 7439.00);
INSERT INTO sales.orders VALUES (48, 48, 48, '2026-05-26', 'Processing', 7576.00);
INSERT INTO sales.orders VALUES (49, 49, 49, '2026-05-29', 'Shipped', 7713.00);
INSERT INTO sales.orders VALUES (50, 50, 50, '2026-06-01', 'Cancelled', 7850.00);
INSERT INTO sales.orders VALUES (51, 1, 51, '2026-06-04', 'Completed', 7987.00);
INSERT INTO sales.orders VALUES (52, 2, 52, '2026-06-07', 'Completed', 8124.00);
INSERT INTO sales.orders VALUES (53, 3, 53, '2026-06-10', 'Processing', 8261.00);
INSERT INTO sales.orders VALUES (54, 4, 54, '2026-06-13', 'Shipped', 8398.00);
INSERT INTO sales.orders VALUES (55, 5, 55, '2026-06-16', 'Cancelled', 8535.00);
INSERT INTO sales.orders VALUES (56, 6, 56, '2026-06-19', 'Completed', 8672.00);
INSERT INTO sales.orders VALUES (57, 7, 57, '2026-06-22', 'Completed', 8809.00);
INSERT INTO sales.orders VALUES (58, 8, 58, '2026-06-25', 'Processing', 8946.00);
INSERT INTO sales.orders VALUES (59, 9, 59, '2026-06-28', 'Shipped', 9083.00);
INSERT INTO sales.orders VALUES (60, 10, 60, '2026-07-01', 'Cancelled', 9220.00);

INSERT INTO sales.order_items VALUES (1, 1, 1, 2, 99999.00);
INSERT INTO sales.order_items VALUES (2, 2, 2, 3, 74999.00);
INSERT INTO sales.order_items VALUES (3, 3, 3, 4, 58999.00);
INSERT INTO sales.order_items VALUES (4, 4, 4, 1, 64999.00);
INSERT INTO sales.order_items VALUES (5, 5, 5, 2, 47999.00);
INSERT INTO sales.order_items VALUES (6, 6, 6, 3, 29999.00);
INSERT INTO sales.order_items VALUES (7, 7, 7, 4, 64999.00);
INSERT INTO sales.order_items VALUES (8, 8, 8, 1, 24999.00);
INSERT INTO sales.order_items VALUES (9, 9, 9, 2, 28999.00);
INSERT INTO sales.order_items VALUES (10, 10, 10, 3, 55999.00);
INSERT INTO sales.order_items VALUES (11, 11, 11, 4, 62999.00);
INSERT INTO sales.order_items VALUES (12, 12, 12, 1, 1999.00);
INSERT INTO sales.order_items VALUES (13, 13, 13, 2, 5999.00);
INSERT INTO sales.order_items VALUES (14, 14, 14, 3, 41999.00);
INSERT INTO sales.order_items VALUES (15, 15, 15, 4, 45999.00);
INSERT INTO sales.order_items VALUES (16, 16, 16, 1, 8999.00);
INSERT INTO sales.order_items VALUES (17, 17, 17, 2, 49999.00);
INSERT INTO sales.order_items VALUES (18, 18, 18, 3, 79999.00);
INSERT INTO sales.order_items VALUES (19, 19, 19, 4, 39999.00);
INSERT INTO sales.order_items VALUES (20, 20, 20, 1, 34999.00);
INSERT INTO sales.order_items VALUES (21, 21, 21, 2, 109999.00);
INSERT INTO sales.order_items VALUES (22, 22, 22, 3, 59999.00);
INSERT INTO sales.order_items VALUES (23, 23, 23, 4, 46999.00);
INSERT INTO sales.order_items VALUES (24, 24, 24, 1, 34999.00);
INSERT INTO sales.order_items VALUES (25, 25, 25, 2, 29999.00);
INSERT INTO sales.order_items VALUES (26, 26, 26, 3, 39999.00);
INSERT INTO sales.order_items VALUES (27, 27, 27, 4, 13999.00);
INSERT INTO sales.order_items VALUES (28, 28, 28, 1, 12999.00);
INSERT INTO sales.order_items VALUES (29, 29, 29, 2, 89999.00);
INSERT INTO sales.order_items VALUES (30, 30, 30, 3, 129999.00);
INSERT INTO sales.order_items VALUES (31, 31, 31, 4, 89999.00);
INSERT INTO sales.order_items VALUES (32, 32, 32, 1, 44999.00);
INSERT INTO sales.order_items VALUES (33, 33, 33, 2, 1299.00);
INSERT INTO sales.order_items VALUES (34, 34, 34, 3, 10999.00);
INSERT INTO sales.order_items VALUES (35, 35, 35, 4, 8999.00);
INSERT INTO sales.order_items VALUES (36, 36, 36, 1, 6999.00);
INSERT INTO sales.order_items VALUES (37, 37, 37, 2, 4999.00);
INSERT INTO sales.order_items VALUES (38, 38, 38, 3, 7999.00);
INSERT INTO sales.order_items VALUES (39, 39, 39, 4, 24999.00);
INSERT INTO sales.order_items VALUES (40, 40, 40, 1, 36999.00);
INSERT INTO sales.order_items VALUES (41, 41, 41, 2, 69999.00);
INSERT INTO sales.order_items VALUES (42, 42, 42, 3, 29999.00);
INSERT INTO sales.order_items VALUES (43, 43, 43, 4, 21999.00);
INSERT INTO sales.order_items VALUES (44, 44, 44, 1, 74999.00);
INSERT INTO sales.order_items VALUES (45, 45, 45, 2, 84999.00);
INSERT INTO sales.order_items VALUES (46, 46, 46, 3, 79999.00);
INSERT INTO sales.order_items VALUES (47, 47, 47, 4, 91999.00);
INSERT INTO sales.order_items VALUES (48, 48, 48, 1, 89999.00);
INSERT INTO sales.order_items VALUES (49, 49, 49, 2, 31999.00);
INSERT INTO sales.order_items VALUES (50, 50, 50, 3, 36999.00);
INSERT INTO sales.order_items VALUES (51, 51, 51, 4, 9999.00);
INSERT INTO sales.order_items VALUES (52, 52, 52, 1, 2499.00);
INSERT INTO sales.order_items VALUES (53, 53, 53, 2, 11999.00);
INSERT INTO sales.order_items VALUES (54, 54, 54, 3, 72999.00);
INSERT INTO sales.order_items VALUES (55, 55, 1, 4, 99999.00);
INSERT INTO sales.order_items VALUES (56, 56, 2, 1, 74999.00);
INSERT INTO sales.order_items VALUES (57, 57, 3, 2, 58999.00);
INSERT INTO sales.order_items VALUES (58, 58, 4, 3, 64999.00);
INSERT INTO sales.order_items VALUES (59, 59, 5, 4, 47999.00);
INSERT INTO sales.order_items VALUES (60, 60, 6, 1, 29999.00);

INSERT INTO sales.payments VALUES (1, 1, '2026-01-06', 'UPI', 'Paid', 1173.00);
INSERT INTO sales.payments VALUES (2, 2, '2026-01-09', 'Credit Card', 'Paid', 1346.00);
INSERT INTO sales.payments VALUES (3, 3, '2026-01-12', 'Debit Card', 'Paid', 1519.00);
INSERT INTO sales.payments VALUES (4, 4, '2026-01-15', 'Net Banking', 'Pending', 1692.00);
INSERT INTO sales.payments VALUES (5, 5, '2026-01-18', 'Cash', 'Failed', 1865.00);
INSERT INTO sales.payments VALUES (6, 6, '2026-01-21', 'UPI', 'Paid', 2038.00);
INSERT INTO sales.payments VALUES (7, 7, '2026-01-24', 'Credit Card', 'Paid', 2211.00);
INSERT INTO sales.payments VALUES (8, 8, '2026-01-27', 'Debit Card', 'Paid', 2384.00);
INSERT INTO sales.payments VALUES (9, 9, '2026-01-30', 'Net Banking', 'Pending', 2557.00);
INSERT INTO sales.payments VALUES (10, 10, '2026-02-02', 'Cash', 'Failed', 2730.00);
INSERT INTO sales.payments VALUES (11, 11, '2026-02-05', 'UPI', 'Paid', 2903.00);
INSERT INTO sales.payments VALUES (12, 12, '2026-02-08', 'Credit Card', 'Paid', 3076.00);
INSERT INTO sales.payments VALUES (13, 13, '2026-02-11', 'Debit Card', 'Paid', 3249.00);
INSERT INTO sales.payments VALUES (14, 14, '2026-02-14', 'Net Banking', 'Pending', 3422.00);
INSERT INTO sales.payments VALUES (15, 15, '2026-02-17', 'Cash', 'Failed', 3595.00);
INSERT INTO sales.payments VALUES (16, 16, '2026-02-20', 'UPI', 'Paid', 3768.00);
INSERT INTO sales.payments VALUES (17, 17, '2026-02-23', 'Credit Card', 'Paid', 3941.00);
INSERT INTO sales.payments VALUES (18, 18, '2026-02-26', 'Debit Card', 'Paid', 4114.00);
INSERT INTO sales.payments VALUES (19, 19, '2026-03-01', 'Net Banking', 'Pending', 4287.00);
INSERT INTO sales.payments VALUES (20, 20, '2026-03-04', 'Cash', 'Failed', 4460.00);
INSERT INTO sales.payments VALUES (21, 21, '2026-03-07', 'UPI', 'Paid', 4633.00);
INSERT INTO sales.payments VALUES (22, 22, '2026-03-10', 'Credit Card', 'Paid', 4806.00);
INSERT INTO sales.payments VALUES (23, 23, '2026-03-13', 'Debit Card', 'Paid', 4979.00);
INSERT INTO sales.payments VALUES (24, 24, '2026-03-16', 'Net Banking', 'Pending', 5152.00);
INSERT INTO sales.payments VALUES (25, 25, '2026-03-19', 'Cash', 'Failed', 5325.00);
INSERT INTO sales.payments VALUES (26, 26, '2026-03-22', 'UPI', 'Paid', 5498.00);
INSERT INTO sales.payments VALUES (27, 27, '2026-03-25', 'Credit Card', 'Paid', 5671.00);
INSERT INTO sales.payments VALUES (28, 28, '2026-03-28', 'Debit Card', 'Paid', 5844.00);
INSERT INTO sales.payments VALUES (29, 29, '2026-03-31', 'Net Banking', 'Pending', 6017.00);
INSERT INTO sales.payments VALUES (30, 30, '2026-04-03', 'Cash', 'Failed', 6190.00);
INSERT INTO sales.payments VALUES (31, 31, '2026-04-06', 'UPI', 'Paid', 6363.00);
INSERT INTO sales.payments VALUES (32, 32, '2026-04-09', 'Credit Card', 'Paid', 6536.00);
INSERT INTO sales.payments VALUES (33, 33, '2026-04-12', 'Debit Card', 'Paid', 6709.00);
INSERT INTO sales.payments VALUES (34, 34, '2026-04-15', 'Net Banking', 'Pending', 6882.00);
INSERT INTO sales.payments VALUES (35, 35, '2026-04-18', 'Cash', 'Failed', 7055.00);
INSERT INTO sales.payments VALUES (36, 36, '2026-04-21', 'UPI', 'Paid', 7228.00);
INSERT INTO sales.payments VALUES (37, 37, '2026-04-24', 'Credit Card', 'Paid', 7401.00);
INSERT INTO sales.payments VALUES (38, 38, '2026-04-27', 'Debit Card', 'Paid', 7574.00);
INSERT INTO sales.payments VALUES (39, 39, '2026-04-30', 'Net Banking', 'Pending', 7747.00);
INSERT INTO sales.payments VALUES (40, 40, '2026-05-03', 'Cash', 'Failed', 7920.00);
INSERT INTO sales.payments VALUES (41, 41, '2026-05-06', 'UPI', 'Paid', 8093.00);
INSERT INTO sales.payments VALUES (42, 42, '2026-05-09', 'Credit Card', 'Paid', 8266.00);
INSERT INTO sales.payments VALUES (43, 43, '2026-05-12', 'Debit Card', 'Paid', 8439.00);
INSERT INTO sales.payments VALUES (44, 44, '2026-05-15', 'Net Banking', 'Pending', 8612.00);
INSERT INTO sales.payments VALUES (45, 45, '2026-05-18', 'Cash', 'Failed', 8785.00);
INSERT INTO sales.payments VALUES (46, 1, '2026-01-06', 'UPI', 'Paid', 1173.00);
INSERT INTO sales.payments VALUES (47, 2, '2026-01-09', 'Credit Card', 'Paid', 1346.00);
INSERT INTO sales.payments VALUES (48, 3, '2026-01-12', 'Debit Card', 'Paid', 1519.00);
INSERT INTO sales.payments VALUES (49, 4, '2026-01-15', 'Net Banking', 'Pending', 1692.00);
INSERT INTO sales.payments VALUES (50, 5, '2026-01-18', 'Cash', 'Failed', 1865.00);
INSERT INTO sales.payments VALUES (51, 6, '2026-01-21', 'UPI', 'Paid', 2038.00);
INSERT INTO sales.payments VALUES (52, 7, '2026-01-24', 'Credit Card', 'Paid', 2211.00);
INSERT INTO sales.payments VALUES (53, 8, '2026-01-27', 'Debit Card', 'Paid', 2384.00);
INSERT INTO sales.payments VALUES (54, 9, '2026-01-30', 'Net Banking', 'Pending', 2557.00);
INSERT INTO sales.payments VALUES (55, 10, '2026-02-02', 'Cash', 'Failed', 2730.00);
INSERT INTO sales.payments VALUES (56, 11, '2026-02-05', 'UPI', 'Paid', 2903.00);
INSERT INTO sales.payments VALUES (57, 12, '2026-02-08', 'Credit Card', 'Paid', 3076.00);
INSERT INTO sales.payments VALUES (58, 13, '2026-02-11', 'Debit Card', 'Paid', 3249.00);
INSERT INTO sales.payments VALUES (59, 14, '2026-02-14', 'Net Banking', 'Pending', 3422.00);
INSERT INTO sales.payments VALUES (60, 15, '2026-02-17', 'Cash', 'Failed', 3595.00);

INSERT INTO sales.shipments VALUES (1, 1, '2026-01-07', '2026-01-10', 'BlueDart', 'Delivered');
INSERT INTO sales.shipments VALUES (2, 2, '2026-01-10', '2026-01-13', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (3, 3, '2026-01-13', '2026-01-16', 'DTDC', 'Shipped');
INSERT INTO sales.shipments VALUES (4, 4, '2026-01-16', '2026-01-19', 'Ecom Express', 'In Transit');
INSERT INTO sales.shipments VALUES (5, 5, '2026-01-19', NULL, 'XpressBees', 'Returned');
INSERT INTO sales.shipments VALUES (6, 6, '2026-01-22', '2026-01-25', 'BlueDart', 'Delivered');
INSERT INTO sales.shipments VALUES (7, 7, '2026-01-25', '2026-01-28', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (8, 8, '2026-01-28', '2026-01-31', 'DTDC', 'Shipped');
INSERT INTO sales.shipments VALUES (9, 9, '2026-01-31', '2026-02-03', 'Ecom Express', 'In Transit');
INSERT INTO sales.shipments VALUES (10, 10, '2026-02-03', NULL, 'XpressBees', 'Returned');
INSERT INTO sales.shipments VALUES (11, 11, '2026-02-06', '2026-02-09', 'BlueDart', 'Delivered');
INSERT INTO sales.shipments VALUES (12, 12, '2026-02-09', '2026-02-12', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (13, 13, '2026-02-12', '2026-02-15', 'DTDC', 'Shipped');
INSERT INTO sales.shipments VALUES (14, 14, '2026-02-15', '2026-02-18', 'Ecom Express', 'In Transit');
INSERT INTO sales.shipments VALUES (15, 15, '2026-02-18', NULL, 'XpressBees', 'Returned');
INSERT INTO sales.shipments VALUES (16, 16, '2026-02-21', '2026-02-24', 'BlueDart', 'Delivered');
INSERT INTO sales.shipments VALUES (17, 17, '2026-02-24', '2026-02-27', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (18, 18, '2026-02-27', '2026-03-02', 'DTDC', 'Shipped');
INSERT INTO sales.shipments VALUES (19, 19, '2026-03-02', '2026-03-05', 'Ecom Express', 'In Transit');
INSERT INTO sales.shipments VALUES (20, 20, '2026-03-05', NULL, 'XpressBees', 'Returned');
INSERT INTO sales.shipments VALUES (21, 21, '2026-03-08', '2026-03-11', 'BlueDart', 'Delivered');
INSERT INTO sales.shipments VALUES (22, 22, '2026-03-11', '2026-03-14', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (23, 23, '2026-03-14', '2026-03-17', 'DTDC', 'Shipped');
INSERT INTO sales.shipments VALUES (24, 24, '2026-03-17', '2026-03-20', 'Ecom Express', 'In Transit');
INSERT INTO sales.shipments VALUES (25, 25, '2026-03-20', NULL, 'XpressBees', 'Returned');
INSERT INTO sales.shipments VALUES (26, 26, '2026-03-23', '2026-03-26', 'BlueDart', 'Delivered');
INSERT INTO sales.shipments VALUES (27, 27, '2026-03-26', '2026-03-29', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (28, 28, '2026-03-29', '2026-04-01', 'DTDC', 'Shipped');
INSERT INTO sales.shipments VALUES (29, 29, '2026-04-01', '2026-04-04', 'Ecom Express', 'In Transit');
INSERT INTO sales.shipments VALUES (30, 30, '2026-04-04', NULL, 'XpressBees', 'Returned');
INSERT INTO sales.shipments VALUES (31, 31, '2026-04-07', '2026-04-10', 'BlueDart', 'Delivered');
INSERT INTO sales.shipments VALUES (32, 32, '2026-04-10', '2026-04-13', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (33, 33, '2026-04-13', '2026-04-16', 'DTDC', 'Shipped');
INSERT INTO sales.shipments VALUES (34, 34, '2026-04-16', '2026-04-19', 'Ecom Express', 'In Transit');
INSERT INTO sales.shipments VALUES (35, 35, '2026-04-19', NULL, 'XpressBees', 'Returned');
INSERT INTO sales.shipments VALUES (36, 36, '2026-04-22', '2026-04-25', 'BlueDart', 'Delivered');
INSERT INTO sales.shipments VALUES (37, 37, '2026-04-25', '2026-04-28', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (38, 38, '2026-04-28', '2026-05-01', 'DTDC', 'Shipped');
INSERT INTO sales.shipments VALUES (39, 39, '2026-05-01', '2026-05-04', 'Ecom Express', 'In Transit');
INSERT INTO sales.shipments VALUES (40, 40, '2026-05-04', NULL, 'XpressBees', 'Returned');
INSERT INTO sales.shipments VALUES (41, 41, '2026-05-07', '2026-05-10', 'BlueDart', 'Delivered');
INSERT INTO sales.shipments VALUES (42, 42, '2026-05-10', '2026-05-13', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (43, 43, '2026-05-13', '2026-05-16', 'DTDC', 'Shipped');
INSERT INTO sales.shipments VALUES (44, 44, '2026-05-16', '2026-05-19', 'Ecom Express', 'In Transit');
INSERT INTO sales.shipments VALUES (45, 45, '2026-05-19', NULL, 'XpressBees', 'Returned');
INSERT INTO sales.shipments VALUES (46, 46, '2026-05-22', '2026-05-25', 'BlueDart', 'Delivered');
INSERT INTO sales.shipments VALUES (47, 47, '2026-05-25', '2026-05-28', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (48, 48, '2026-05-28', '2026-05-31', 'DTDC', 'Shipped');
INSERT INTO sales.shipments VALUES (49, 49, '2026-05-31', '2026-06-03', 'Ecom Express', 'In Transit');
INSERT INTO sales.shipments VALUES (50, 50, '2026-06-03', NULL, 'XpressBees', 'Returned');
INSERT INTO sales.shipments VALUES (51, 1, '2026-01-07', '2026-01-10', 'BlueDart', 'Delivered');
INSERT INTO sales.shipments VALUES (52, 2, '2026-01-10', '2026-01-13', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (53, 3, '2026-01-13', '2026-01-16', 'DTDC', 'Shipped');
INSERT INTO sales.shipments VALUES (54, 4, '2026-01-16', '2026-01-19', 'Ecom Express', 'In Transit');
INSERT INTO sales.shipments VALUES (55, 5, '2026-01-19', NULL, 'XpressBees', 'Returned');
INSERT INTO sales.shipments VALUES (56, 6, '2026-01-22', '2026-01-25', 'BlueDart', 'Delivered');
INSERT INTO sales.shipments VALUES (57, 7, '2026-01-25', '2026-01-28', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (58, 8, '2026-01-28', '2026-01-31', 'DTDC', 'Shipped');
INSERT INTO sales.shipments VALUES (59, 9, '2026-01-31', '2026-02-03', 'Ecom Express', 'In Transit');
INSERT INTO sales.shipments VALUES (60, 10, '2026-02-03', NULL, 'XpressBees', 'Returned');


