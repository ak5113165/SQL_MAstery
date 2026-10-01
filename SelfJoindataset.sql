-- =====================================================================
-- SQL JOIN CLASSROOM DATASET  (v2 - rebuilt so EVERY join type is useful)
-- PostgreSQL
--
-- WHY THIS VERSION EXISTS
--   The original data matched 1-to-1 almost everywhere, so LEFT / RIGHT /
--   FULL OUTER joins returned the same rows as INNER JOIN. Here, every
--   relationship deliberately contains unmatched rows on one or both sides.
--
-- WHERE TO PRACTISE EACH JOIN
--   INNER JOIN       orders o  JOIN customers c        ON o.cust_id = c.customer_id
--   LEFT JOIN        customers c LEFT JOIN orders o    ON ...   (customers who never ordered: WHERE o.order_id IS NULL)
--   RIGHT JOIN       products p RIGHT JOIN order_items ON ...   (or: orders RIGHT JOIN customers)
--   FULL OUTER JOIN  customers c FULL JOIN orders o    ON ...   (customers with no orders AND guest orders with no customer)
--                    stores s FULL JOIN employees e    ON ...   (stores with no staff AND unassigned employees)
--                    core.dim_brand b FULL JOIN products p ON ... (brands with no products AND unbranded products)
--   SELF JOIN        employees e JOIN employees m      ON e.manager_id = m.employee_id
--                    customers c LEFT JOIN customers r ON c.referred_by = r.customer_id
--                    products p1 JOIN products p2      ON p1.category = p2.category AND p1.prod_id < p2.prod_id
--                    employees e1 JOIN employees e2 ON e1.dept_id = e2.dept_id AND e1.employee_id < e2.employee_id
--                        JOIN core.dim_department d ON e1.dept_id = d.dept_id   (colleague pairs in the same department)
--   CROSS JOIN       core.dim_color CROSS JOIN core.dim_storage   (5 x 4 = 20 variants)
--   NON-EQUI JOIN    products p JOIN core.dim_price_band b ON p.price BETWEEN b.min_price AND b.max_price
--   ANTI JOIN        LEFT JOIN ... WHERE right.pk IS NULL  (or NOT EXISTS)
--   SEMI JOIN        WHERE EXISTS (...)
--   MULTI-TABLE      customers -> orders -> order_items -> products -> dim_brand
--   ONE-TO-MANY      orders -> payments (split payments), orders -> shipments (split shipments)
--
-- SCHEMA CHANGES vs. the original file
--   customers.customers.referred_by   NEW  (self-reference for self join)
--   stores.employees.manager_id       NEW  (self-reference for self join)
--   stores.employees.first_name/last_name/role/dept_id   NEW (employee_name is now derived; job_title renamed to role)
--   core.dim_department               NEW  (10 departments, 2 of them with no employees)
--   stores.employees.store_id         now NULLABLE (unassigned employees)
--   products.products.brand_id        now NULLABLE (unbranded products)
--   sales.orders.cust_id              now NULLABLE (guest checkouts)
--   core.dim_color / dim_storage / dim_price_band   NEW small helper tables
--
-- EXPECTED RESULTS (verified on PostgreSQL 16) - use these to check your queries
--   INNER  orders-customers ............ 54 rows
--   LEFT   customers-orders ............ 73 rows  (19 customers have no orders)
--   RIGHT  customers-orders ............ 60 rows  (6 guest orders have no customer)
--   FULL   customers-orders ............ 79 rows  (19 customer-only + 6 order-only + 54 matched)
--   FULL   stores-employees ............ 80 rows  (20 stores w/o staff, 8 staff w/o store)
--   FULL   dim_brand-products .......... 65 rows  (5 brands w/o products, 5 unbranded products)
--   SELF   employee -> manager ......... 57 matched, 3 have no manager, 3 earn more than their manager
--   SELF   same-department pairs ...... 215 pairs (e1.employee_id < e2.employee_id, joined to dim_department)
--   LEFT   dim_department-employees .... 2 departments (Legal, R&D) have no employees; 2 contractors have no department
--   SELF   customer -> referrer ........ 36 customers were referred by another customer
--   SELF   same-category product pairs . 204 pairs (p1.prod_id < p2.prod_id)
--   CROSS  color x storage ............. 20 rows
--   Products never sold ................ 12   |  Draft orders with no items ... 8
--   Orders with no payment ............. 18   |  Orders with >1 payment ....... 5
--   Orders with no shipment ............ 28   |  Orders with >1 shipment ...... 3
-- =====================================================================

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
    email VARCHAR(120),
    referred_by INT REFERENCES customers.customers(customer_id)   -- self join
);

CREATE TABLE stores.stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    state VARCHAR(50)
);

CREATE TABLE core.dim_department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL
);

CREATE TABLE stores.employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    employee_name VARCHAR(101) GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
    store_id INT REFERENCES stores.stores(store_id),              -- NULL = unassigned
    dept_id INT REFERENCES core.dim_department(dept_id),          -- NULL = no department
    role VARCHAR(50),
    salary INT,
    manager_id INT REFERENCES stores.employees(employee_id)       -- self join
);

CREATE TABLE core.dim_brand (
    brand_id INT PRIMARY KEY,
    brand_name VARCHAR(100) NOT NULL,
    country VARCHAR(50)
);

CREATE TABLE core.dim_color (
    color_id INT PRIMARY KEY,
    color_name VARCHAR(30) NOT NULL
);

CREATE TABLE core.dim_storage (
    storage_id INT PRIMARY KEY,
    storage_size VARCHAR(30) NOT NULL
);

CREATE TABLE core.dim_price_band (
    band_id INT PRIMARY KEY,
    band_name VARCHAR(30) NOT NULL,
    min_price NUMERIC(10,2) NOT NULL,
    max_price NUMERIC(10,2) NOT NULL
);

CREATE TABLE products.products (
    prod_id INT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(50),
    brand_id INT REFERENCES core.dim_brand(brand_id),             -- NULL = unbranded
    price NUMERIC(10,2)
);

CREATE TABLE sales.orders (
    order_id INT PRIMARY KEY,
    cust_id INT REFERENCES customers.customers(customer_id),      -- NULL = guest checkout
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

-- =========================
-- 2. DATA
-- =========================


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
INSERT INTO core.dim_brand VALUES (11, 'Acer', 'Taiwan');
INSERT INTO core.dim_brand VALUES (12, 'Boat', 'India');
INSERT INTO core.dim_brand VALUES (13, 'JBL', 'USA');
INSERT INTO core.dim_brand VALUES (14, 'Canon', 'Japan');
INSERT INTO core.dim_brand VALUES (15, 'Nikon', 'Japan');
INSERT INTO core.dim_brand VALUES (16, 'Logitech', 'Switzerland');
INSERT INTO core.dim_brand VALUES (17, 'Microsoft', 'USA');
INSERT INTO core.dim_brand VALUES (18, 'Google', 'USA');
INSERT INTO core.dim_brand VALUES (19, 'Realme', 'China');
INSERT INTO core.dim_brand VALUES (20, 'Vivo', 'China');
INSERT INTO core.dim_brand VALUES (21, 'Motorola', 'USA');
INSERT INTO core.dim_brand VALUES (22, 'Nothing', 'UK');
INSERT INTO core.dim_brand VALUES (23, 'Panasonic', 'Japan');
INSERT INTO core.dim_brand VALUES (24, 'Philips', 'Netherlands');
INSERT INTO core.dim_brand VALUES (25, 'Bose', 'USA');

INSERT INTO core.dim_department VALUES (1, 'Sales');
INSERT INTO core.dim_department VALUES (2, 'Customer Support');
INSERT INTO core.dim_department VALUES (3, 'Inventory & Logistics');
INSERT INTO core.dim_department VALUES (4, 'Finance');
INSERT INTO core.dim_department VALUES (5, 'Store Operations');
INSERT INTO core.dim_department VALUES (6, 'Human Resources');
INSERT INTO core.dim_department VALUES (7, 'IT');
INSERT INTO core.dim_department VALUES (8, 'Marketing');
INSERT INTO core.dim_department VALUES (9, 'Legal');
INSERT INTO core.dim_department VALUES (10, 'Research & Development');

INSERT INTO core.dim_color VALUES (1, 'Black');
INSERT INTO core.dim_color VALUES (2, 'Silver');
INSERT INTO core.dim_color VALUES (3, 'Blue');
INSERT INTO core.dim_color VALUES (4, 'Red');
INSERT INTO core.dim_color VALUES (5, 'White');

INSERT INTO core.dim_storage VALUES (1, '128 GB');
INSERT INTO core.dim_storage VALUES (2, '256 GB');
INSERT INTO core.dim_storage VALUES (3, '512 GB');
INSERT INTO core.dim_storage VALUES (4, '1 TB');

INSERT INTO core.dim_price_band VALUES (1, 'Budget', 0, 9999.99);
INSERT INTO core.dim_price_band VALUES (2, 'Mid-range', 10000, 29999.99);
INSERT INTO core.dim_price_band VALUES (3, 'Premium', 30000, 59999.99);
INSERT INTO core.dim_price_band VALUES (4, 'Flagship', 60000, 999999.99);

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

INSERT INTO customers.customers VALUES (1, 'Ankit 1', 'Delhi', 'Delhi', 'ankit1@example.com', NULL);
INSERT INTO customers.customers VALUES (2, 'Rahul 2', 'Noida', 'Uttar Pradesh', 'rahul2@example.com', NULL);
INSERT INTO customers.customers VALUES (3, 'Priya 3', 'Gurgaon', 'Haryana', 'priya3@example.com', NULL);
INSERT INTO customers.customers VALUES (4, 'Aman 4', 'Jaipur', 'Rajasthan', 'aman4@example.com', NULL);
INSERT INTO customers.customers VALUES (5, 'Neha 5', 'Lucknow', 'Uttar Pradesh', 'neha5@example.com', NULL);
INSERT INTO customers.customers VALUES (6, 'Rohit 6', 'Pune', 'Maharashtra', 'rohit6@example.com', NULL);
INSERT INTO customers.customers VALUES (7, 'Sneha 7', 'Mumbai', 'Maharashtra', 'sneha7@example.com', NULL);
INSERT INTO customers.customers VALUES (8, 'Vikas 8', 'Bengaluru', 'Karnataka', 'vikas8@example.com', NULL);
INSERT INTO customers.customers VALUES (9, 'Pooja 9', 'Chandigarh', 'Chandigarh', 'pooja9@example.com', NULL);
INSERT INTO customers.customers VALUES (10, 'Arjun 10', 'Hyderabad', 'Telangana', 'arjun10@example.com', NULL);
INSERT INTO customers.customers VALUES (11, 'Karan 11', 'Delhi', 'Delhi', 'karan11@example.com', NULL);
INSERT INTO customers.customers VALUES (12, 'Simran 12', 'Noida', 'Uttar Pradesh', 'simran12@example.com', NULL);
INSERT INTO customers.customers VALUES (13, 'Aditya 13', 'Gurgaon', 'Haryana', 'aditya13@example.com', 8);
INSERT INTO customers.customers VALUES (14, 'Nisha 14', 'Jaipur', 'Rajasthan', 'nisha14@example.com', 8);
INSERT INTO customers.customers VALUES (15, 'Varun 15', 'Lucknow', 'Uttar Pradesh', 'varun15@example.com', 8);
INSERT INTO customers.customers VALUES (16, 'Kavya 16', 'Pune', 'Maharashtra', 'kavya16@example.com', NULL);
INSERT INTO customers.customers VALUES (17, 'Manish 17', 'Mumbai', 'Maharashtra', 'manish17@example.com', 8);
INSERT INTO customers.customers VALUES (18, 'Riya 18', 'Bengaluru', 'Karnataka', 'riya18@example.com', 8);
INSERT INTO customers.customers VALUES (19, 'Saurabh 19', 'Chandigarh', 'Chandigarh', 'saurabh19@example.com', 8);
INSERT INTO customers.customers VALUES (20, 'Isha 20', 'Hyderabad', 'Telangana', 'isha20@example.com', NULL);
INSERT INTO customers.customers VALUES (21, 'Mohit 21', 'Delhi', 'Delhi', 'mohit21@example.com', 8);
INSERT INTO customers.customers VALUES (22, 'Shreya 22', 'Noida', 'Uttar Pradesh', 'shreya22@example.com', 8);
INSERT INTO customers.customers VALUES (23, 'Nitin 23', 'Gurgaon', 'Haryana', 'nitin23@example.com', 8);
INSERT INTO customers.customers VALUES (24, 'Anjali 24', 'Jaipur', 'Rajasthan', 'anjali24@example.com', NULL);
INSERT INTO customers.customers VALUES (25, 'Deepak 25', 'Lucknow', 'Uttar Pradesh', 'deepak25@example.com', 8);
INSERT INTO customers.customers VALUES (26, 'Meera 26', 'Pune', 'Maharashtra', 'meera26@example.com', 8);
INSERT INTO customers.customers VALUES (27, 'Abhishek 27', 'Mumbai', 'Maharashtra', 'abhishek27@example.com', 8);
INSERT INTO customers.customers VALUES (28, 'Tanya 28', 'Bengaluru', 'Karnataka', 'tanya28@example.com', NULL);
INSERT INTO customers.customers VALUES (29, 'Yash 29', 'Chandigarh', 'Chandigarh', 'yash29@example.com', 8);
INSERT INTO customers.customers VALUES (30, 'Aditi 30', 'Hyderabad', 'Telangana', 'aditi30@example.com', 8);
INSERT INTO customers.customers VALUES (31, 'Ravi 31', 'Delhi', 'Delhi', 'ravi31@example.com', 8);
INSERT INTO customers.customers VALUES (32, 'Sakshi 32', 'Noida', 'Uttar Pradesh', 'sakshi32@example.com', NULL);
INSERT INTO customers.customers VALUES (33, 'Harsh 33', 'Gurgaon', 'Haryana', 'harsh33@example.com', 8);
INSERT INTO customers.customers VALUES (34, 'Muskan 34', 'Jaipur', 'Rajasthan', 'muskan34@example.com', 8);
INSERT INTO customers.customers VALUES (35, 'Akash 35', 'Lucknow', 'Uttar Pradesh', 'akash35@example.com', 8);
INSERT INTO customers.customers VALUES (36, 'Divya 36', 'Pune', 'Maharashtra', 'divya36@example.com', NULL);
INSERT INTO customers.customers VALUES (37, 'Gaurav 37', 'Mumbai', 'Maharashtra', 'gaurav37@example.com', 8);
INSERT INTO customers.customers VALUES (38, 'Komal 38', 'Bengaluru', 'Karnataka', 'komal38@example.com', 8);
INSERT INTO customers.customers VALUES (39, 'Ayush 39', 'Chandigarh', 'Chandigarh', 'ayush39@example.com', 8);
INSERT INTO customers.customers VALUES (40, 'Preeti 40', 'Hyderabad', 'Telangana', 'preeti40@example.com', NULL);
INSERT INTO customers.customers VALUES (41, 'Vivek 41', 'Delhi', 'Delhi', 'vivek41@example.com', 8);
INSERT INTO customers.customers VALUES (42, 'Swati 42', 'Noida', 'Uttar Pradesh', 'swati42@example.com', 8);
INSERT INTO customers.customers VALUES (43, 'Rakesh 43', 'Gurgaon', 'Haryana', 'rakesh43@example.com', 8);
INSERT INTO customers.customers VALUES (44, 'Pallavi 44', 'Jaipur', 'Rajasthan', 'pallavi44@example.com', NULL);
INSERT INTO customers.customers VALUES (45, 'Sumit 45', 'Lucknow', 'Uttar Pradesh', 'sumit45@example.com', 8);
INSERT INTO customers.customers VALUES (46, 'Tanvi 46', 'Pune', 'Maharashtra', 'tanvi46@example.com', 8);
INSERT INTO customers.customers VALUES (47, 'Rajat 47', 'Mumbai', 'Maharashtra', 'rajat47@example.com', 8);
INSERT INTO customers.customers VALUES (48, 'Mansi 48', 'Bengaluru', 'Karnataka', 'mansi48@example.com', NULL);
INSERT INTO customers.customers VALUES (49, 'Aakash 49', 'Chandigarh', 'Chandigarh', 'aakash49@example.com', 8);
INSERT INTO customers.customers VALUES (50, 'Kirti 50', 'Hyderabad', 'Telangana', 'kirti50@example.com', 8);
INSERT INTO customers.customers VALUES (51, 'Aarav 51', 'Delhi', 'Delhi', 'aarav51@example.com', 8);
INSERT INTO customers.customers VALUES (52, 'Ananya 52', 'Noida', 'Uttar Pradesh', 'ananya52@example.com', NULL);
INSERT INTO customers.customers VALUES (53, 'Dev 53', 'Gurgaon', 'Haryana', 'dev53@example.com', 8);
INSERT INTO customers.customers VALUES (54, 'Ishita 54', 'Jaipur', 'Rajasthan', 'ishita54@example.com', 8);
INSERT INTO customers.customers VALUES (55, 'Kabir 55', 'Lucknow', 'Uttar Pradesh', 'kabir55@example.com', 8);
INSERT INTO customers.customers VALUES (56, 'Navya 56', 'Pune', 'Maharashtra', 'navya56@example.com', NULL);
INSERT INTO customers.customers VALUES (57, 'Rohan 57', 'Mumbai', 'Maharashtra', 'rohan57@example.com', 8);
INSERT INTO customers.customers VALUES (58, 'Sanya 58', 'Bengaluru', 'Karnataka', 'sanya58@example.com', 8);
INSERT INTO customers.customers VALUES (59, 'Varun 59', 'Chandigarh', 'Chandigarh', 'varun59@example.com', 8);
INSERT INTO customers.customers VALUES (60, 'Zoya 60', 'Hyderabad', 'Telangana', 'zoya60@example.com', NULL);

INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (1, 'Manish', 'Kumar', 1, 5, 'General Manager', 150000, NULL);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (2, 'Riya', 'Yadav', 2, 5, 'Regional Manager', 70000, 1);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (3, 'Saurabh', 'Nair', 3, 5, 'Regional Manager', 72500, 1);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (4, 'Isha', 'Verma', 4, 5, 'Regional Manager', 75000, 1);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (5, 'Mohit', 'Mehta', 5, 5, 'Regional Manager', 77500, 1);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (6, 'Shreya', 'Chopra', 6, 5, 'Regional Manager', 80000, 1);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (7, 'Nitin', 'Iyer', 7, 1, 'Sales Executive', 43000, 2);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (8, 'Anjali', 'Gupta', 8, 2, 'Support Executive', 45500, 3);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (9, 'Deepak', 'Agarwal', 9, 3, 'Inventory Associate', 48000, 4);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (10, 'Meera', 'Malhotra', 10, 4, 'Cashier', 50500, 5);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (11, 'Abhishek', 'Bansal', 11, 1, 'Sales Executive', 28000, 6);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (12, 'Tanya', 'Singh', 12, 2, 'Support Executive', 30500, 2);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (13, 'Yash', 'Jain', 13, 5, 'Store Manager', 33000, 3);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (14, 'Aditi', 'Reddy', 14, 6, 'HR Executive', 35500, 4);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (15, 'Ravi', 'Sharma', 15, 7, 'IT Support Engineer', 38000, 5);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (16, 'Sakshi', 'Kumar', 16, 8, 'Marketing Executive', 40500, 6);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (17, 'Harsh', 'Yadav', 17, 1, 'Sales Executive', 43000, 2);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (18, 'Muskan', 'Nair', 18, 2, 'Support Executive', 45500, 3);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (19, 'Akash', 'Verma', 19, 3, 'Inventory Associate', 48000, 4);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (20, 'Divya', 'Mehta', 20, 4, 'Cashier', 80000, 5);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (21, 'Gaurav', 'Chopra', 21, 1, 'Sales Executive', 28000, 6);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (22, 'Komal', 'Iyer', 22, 2, 'Support Executive', 30500, 2);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (23, 'Ayush', 'Gupta', 23, 5, 'Store Manager', 33000, 3);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (24, 'Preeti', 'Agarwal', 24, 6, 'HR Executive', 35500, 4);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (25, 'Vivek', 'Malhotra', 25, 7, 'IT Support Engineer', 38000, 5);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (26, 'Swati', 'Bansal', 26, 8, 'Marketing Executive', 40500, 6);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (27, 'Rakesh', 'Singh', 27, 1, 'Sales Executive', 43000, 2);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (28, 'Pallavi', 'Jain', 28, 2, 'Support Executive', 45500, 3);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (29, 'Sumit', 'Reddy', 29, 3, 'Inventory Associate', 48000, 4);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (30, 'Tanvi', 'Sharma', 30, 4, 'Cashier', 50500, 5);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (31, 'Rajat', 'Kumar', 31, 1, 'Sales Executive', 28000, 6);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (32, 'Mansi', 'Yadav', 32, 2, 'Support Executive', 30500, 2);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (33, 'Aakash', 'Nair', 33, 5, 'Store Manager', 80000, 3);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (34, 'Kirti', 'Verma', 34, 6, 'HR Executive', 35500, 4);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (35, 'Aarav', 'Mehta', 35, 7, 'IT Support Engineer', 38000, 5);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (36, 'Ananya', 'Chopra', 36, 8, 'Marketing Executive', 40500, 6);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (37, 'Dev', 'Iyer', 37, 1, 'Sales Executive', 43000, 2);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (38, 'Ishita', 'Gupta', 38, 2, 'Support Executive', 45500, 3);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (39, 'Kabir', 'Agarwal', 39, 3, 'Inventory Associate', 48000, 4);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (40, 'Navya', 'Malhotra', 40, 4, 'Cashier', 50500, 5);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (41, 'Rohan', 'Bansal', 1, 1, 'Sales Executive', 28000, 6);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (42, 'Sanya', 'Singh', 2, 2, 'Support Executive', 30500, 2);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (43, 'Varun', 'Jain', 3, 5, 'Store Manager', 33000, 3);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (44, 'Zoya', 'Reddy', 4, 6, 'HR Executive', 35500, 4);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (45, 'Ankit', 'Sharma', 5, 7, 'IT Support Engineer', 38000, 5);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (46, 'Rahul', 'Kumar', 6, 8, 'Marketing Executive', 40500, 6);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (47, 'Priya', 'Yadav', 7, 1, 'Sales Executive', 80000, 2);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (48, 'Aman', 'Nair', 8, 2, 'Support Executive', 45500, 3);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (49, 'Neha', 'Verma', 9, 3, 'Inventory Associate', 48000, 4);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (50, 'Rohit', 'Mehta', 10, 4, 'Cashier', 50500, 5);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (51, 'Sneha', 'Chopra', 11, 1, 'Sales Executive', 28000, 6);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (52, 'Vikas', 'Iyer', 12, 2, 'Support Executive', 30500, 2);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (53, 'Pooja', 'Gupta', NULL, 5, 'Store Manager', 33000, 3);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (54, 'Arjun', 'Agarwal', NULL, 6, 'HR Executive', 35500, 4);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (55, 'Karan', 'Malhotra', NULL, 7, 'IT Support Engineer', 38000, 5);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (56, 'Simran', 'Bansal', NULL, 8, 'Marketing Executive', 40500, 6);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (57, 'Aditya', 'Singh', NULL, 1, 'Sales Executive', 43000, 2);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (58, 'Nisha', 'Jain', NULL, 2, 'Support Executive', 45500, 3);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (59, 'Varun', 'Reddy', NULL, NULL, 'Contract Consultant', 48000, NULL);
INSERT INTO stores.employees (employee_id, first_name, last_name, store_id, dept_id, role, salary, manager_id) VALUES (60, 'Kavya', 'Sharma', NULL, NULL, 'Contract Consultant', 50500, NULL);

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
INSERT INTO products.products VALUES (21, 'Samsung 55 OLED 21', 'TV', 2, 109999);
INSERT INTO products.products VALUES (22, 'LG 50 4K TV 22', 'TV', 9, 59999);
INSERT INTO products.products VALUES (23, 'Apple Watch Series 10 23', 'Smartwatch', 1, 46999);
INSERT INTO products.products VALUES (24, 'Galaxy Watch 7 24', 'Smartwatch', 2, 34999);
INSERT INTO products.products VALUES (25, 'Xiaomi Pad 7 25', 'Tablet', 8, 29999);
INSERT INTO products.products VALUES (26, 'OnePlus Pad 2 26', 'Tablet', 7, 39999);
INSERT INTO products.products VALUES (27, 'Dell 24 Monitor 27', 'Monitor', 3, 13999);
INSERT INTO products.products VALUES (28, 'HP 24 Monitor 28', 'Monitor', 4, 12999);
INSERT INTO products.products VALUES (29, 'Lenovo Legion 5 29', 'Laptop', 5, 89999);
INSERT INTO products.products VALUES (30, 'Asus ROG Strix 30', 'Laptop', 10, 129999);
INSERT INTO products.products VALUES (31, 'Sony Bravia 55 31', 'TV', 6, 89999);
INSERT INTO products.products VALUES (32, 'Samsung Galaxy Tab 32', 'Tablet', 2, 44999);
INSERT INTO products.products VALUES (33, 'Boat Airdopes 141 33', 'Headphones', 12, 1299);
INSERT INTO products.products VALUES (34, 'JBL Flip 6 34', 'Headphones', 13, 10999);
INSERT INTO products.products VALUES (35, 'Canon Pixma Printer 35', 'Camera', 14, 8999);
INSERT INTO products.products VALUES (36, 'Logitech G502 36', 'Mouse', 16, 6999);
INSERT INTO products.products VALUES (37, 'Microsoft Surface Mouse 37', 'Mouse', 17, 4999);
INSERT INTO products.products VALUES (38, 'Apple Magic Mouse 38', 'Mouse', 1, 7999);
INSERT INTO products.products VALUES (39, 'OnePlus Nord CE 39', 'Mobile', 7, 24999);
INSERT INTO products.products VALUES (40, 'Samsung A55 40', 'Mobile', 2, 36999);
INSERT INTO products.products VALUES (41, 'Xiaomi 14 41', 'Mobile', 8, 69999);
INSERT INTO products.products VALUES (42, 'Realme 13 Pro 42', 'Mobile', 19, 29999);
INSERT INTO products.products VALUES (43, 'Vivo T3 43', 'Mobile', 20, 21999);
INSERT INTO products.products VALUES (44, 'Acer Nitro V 44', 'Laptop', 11, 74999);
INSERT INTO products.products VALUES (45, 'HP Victus 45', 'Laptop', 4, 84999);
INSERT INTO products.products VALUES (46, 'Lenovo LOQ 46', 'Laptop', 5, 79999);
INSERT INTO products.products VALUES (47, 'Dell G15 47', 'Laptop', 3, 91999);
INSERT INTO products.products VALUES (48, 'Asus TUF Gaming 48', 'Laptop', 10, 89999);
INSERT INTO products.products VALUES (49, 'LG Ultrawide 49', 'Monitor', 9, 31999);
INSERT INTO products.products VALUES (50, 'Samsung Smart Monitor 50', 'Monitor', 2, 36999);
INSERT INTO products.products VALUES (51, 'Sony WH-CH720N 51', 'Headphones', 6, 9999);
INSERT INTO products.products VALUES (52, 'Boat Nirvana 52', 'Headphones', 12, 2499);
INSERT INTO products.products VALUES (53, 'JBL Live 660NC 53', 'Headphones', 13, 11999);
INSERT INTO products.products VALUES (54, 'Canon EOS R50 54', 'Camera', 14, 72999);
INSERT INTO products.products VALUES (55, 'Nikon Z30 55', 'Camera', 15, 65999);
INSERT INTO products.products VALUES (56, 'Generic HDMI Cable', 'Accessory', NULL, 499);
INSERT INTO products.products VALUES (57, 'Generic USB-C Hub', 'Accessory', NULL, 1499);
INSERT INTO products.products VALUES (58, 'Unbranded Laptop Stand', 'Accessory', NULL, 999);
INSERT INTO products.products VALUES (59, 'Generic Webcam Cover', 'Accessory', NULL, 199);
INSERT INTO products.products VALUES (60, 'Generic Phone Tripod', 'Accessory', NULL, 799);

INSERT INTO sales.orders VALUES (1, 8, 1, '2026-01-05', 'Completed', 59998);
INSERT INTO sales.orders VALUES (2, 15, 2, '2026-01-08', 'Completed', 188997);
INSERT INTO sales.orders VALUES (3, 22, 3, '2026-01-11', 'Processing', 36997);
INSERT INTO sales.orders VALUES (4, 29, 4, '2026-01-14', 'Shipped', 219998);
INSERT INTO sales.orders VALUES (5, 36, 5, '2026-01-17', 'Cancelled', 119997);
INSERT INTO sales.orders VALUES (6, 43, 6, '2026-01-20', 'Completed', 149997);
INSERT INTO sales.orders VALUES (7, NULL, 7, '2026-01-23', 'Completed', 289995);
INSERT INTO sales.orders VALUES (8, 12, 8, '2026-01-26', 'Processing', 209997);
INSERT INTO sales.orders VALUES (9, 19, 9, '2026-01-29', 'Shipped', 137997);
INSERT INTO sales.orders VALUES (10, 26, 10, '2026-02-01', 'Cancelled', 117998);
INSERT INTO sales.orders VALUES (11, 33, 11, '2026-02-04', 'Completed', 74997);
INSERT INTO sales.orders VALUES (12, 40, 12, '2026-02-07', 'Completed', 75997);
INSERT INTO sales.orders VALUES (13, 2, 13, '2026-02-10', 'Processing', 159998);
INSERT INTO sales.orders VALUES (14, NULL, 14, '2026-02-13', 'Shipped', 151996);
INSERT INTO sales.orders VALUES (15, 16, 15, '2026-02-16', 'Cancelled', 62997);
INSERT INTO sales.orders VALUES (16, 23, 16, '2026-02-19', 'Completed', 2598);
INSERT INTO sales.orders VALUES (17, 30, 17, '2026-02-22', 'Completed', 23997);
INSERT INTO sales.orders VALUES (18, 37, 18, '2026-02-25', 'Processing', 81997);
INSERT INTO sales.orders VALUES (19, 44, 19, '2026-02-28', 'Shipped', 179998);
INSERT INTO sales.orders VALUES (20, 6, 20, '2026-03-03', 'Cancelled', 143997);
INSERT INTO sales.orders VALUES (21, NULL, 21, '2026-03-06', 'Completed', 410994);
INSERT INTO sales.orders VALUES (22, 20, 22, '2026-03-09', 'Completed', 91998);
INSERT INTO sales.orders VALUES (23, 27, 23, '2026-03-12', 'Processing', 104997);
INSERT INTO sales.orders VALUES (24, 34, 24, '2026-03-15', 'Shipped', 43997);
INSERT INTO sales.orders VALUES (25, 41, 25, '2026-03-18', 'Cancelled', 259998);
INSERT INTO sales.orders VALUES (26, 3, 26, '2026-03-21', 'Completed', 26997);
INSERT INTO sales.orders VALUES (27, 10, 27, '2026-03-24', 'Completed', 154997);
INSERT INTO sales.orders VALUES (28, NULL, 28, '2026-03-27', 'Processing', 244995);
INSERT INTO sales.orders VALUES (29, 24, 29, '2026-03-30', 'Shipped', 224997);
INSERT INTO sales.orders VALUES (30, 31, 30, '2026-04-02', 'Cancelled', 224997);
INSERT INTO sales.orders VALUES (31, 38, 31, '2026-04-05', 'Completed', 3998);
INSERT INTO sales.orders VALUES (32, 45, 32, '2026-04-08', 'Completed', 149997);
INSERT INTO sales.orders VALUES (33, 7, 33, '2026-04-11', 'Processing', 62597);
INSERT INTO sales.orders VALUES (34, 14, 34, '2026-04-14', 'Shipped', 27998);
INSERT INTO sales.orders VALUES (35, NULL, 35, '2026-04-17', 'Cancelled', 156996);
INSERT INTO sales.orders VALUES (36, 28, 36, '2026-04-20', 'Completed', 184997);
INSERT INTO sales.orders VALUES (37, 35, 37, '2026-04-23', 'Completed', 59998);
INSERT INTO sales.orders VALUES (38, 42, 38, '2026-04-26', 'Processing', 275997);
INSERT INTO sales.orders VALUES (39, 4, 39, '2026-04-29', 'Shipped', 156997);
INSERT INTO sales.orders VALUES (40, 11, 40, '2026-05-02', 'Cancelled', 57998);
INSERT INTO sales.orders VALUES (41, 18, 41, '2026-05-05', 'Completed', 125997);
INSERT INTO sales.orders VALUES (42, NULL, 42, '2026-05-08', 'Completed', 509994);
INSERT INTO sales.orders VALUES (43, 32, 43, '2026-05-11', 'Processing', 69998);
INSERT INTO sales.orders VALUES (44, 39, 44, '2026-05-14', 'Shipped', 269997);
INSERT INTO sales.orders VALUES (45, 1, 45, '2026-05-17', 'Cancelled', 180997);
INSERT INTO sales.orders VALUES (46, 8, 46, '2026-05-20', 'Completed', 49998);
INSERT INTO sales.orders VALUES (47, 15, 47, '2026-05-23', 'Completed', 224997);
INSERT INTO sales.orders VALUES (48, 22, 48, '2026-05-26', 'Processing', 103997);
INSERT INTO sales.orders VALUES (49, 29, 49, '2026-05-29', 'Shipped', 209995);
INSERT INTO sales.orders VALUES (50, 36, 50, '2026-06-01', 'Cancelled', 188997);
INSERT INTO sales.orders VALUES (51, 43, 1, '2026-06-04', 'Completed', 36997);
INSERT INTO sales.orders VALUES (52, 5, 2, '2026-06-07', 'Completed', 219998);
INSERT INTO sales.orders VALUES (53, 12, 3, '2026-06-10', 'Draft', 0);
INSERT INTO sales.orders VALUES (54, 19, 4, '2026-06-13', 'Draft', 0);
INSERT INTO sales.orders VALUES (55, 26, 5, '2026-06-16', 'Draft', 0);
INSERT INTO sales.orders VALUES (56, 33, 6, '2026-06-19', 'Draft', 0);
INSERT INTO sales.orders VALUES (57, 40, 7, '2026-06-22', 'Draft', 0);
INSERT INTO sales.orders VALUES (58, 2, 8, '2026-06-25', 'Draft', 0);
INSERT INTO sales.orders VALUES (59, 9, 9, '2026-06-28', 'Draft', 0);
INSERT INTO sales.orders VALUES (60, 16, 10, '2026-07-01', 'Draft', 0);

INSERT INTO sales.order_items VALUES (1, 1, 6, 2, 29999);
INSERT INTO sales.order_items VALUES (2, 2, 11, 3, 62999);
INSERT INTO sales.order_items VALUES (3, 3, 16, 1, 8999);
INSERT INTO sales.order_items VALUES (4, 3, 27, 2, 13999);
INSERT INTO sales.order_items VALUES (5, 4, 21, 2, 109999);
INSERT INTO sales.order_items VALUES (6, 5, 26, 3, 39999);
INSERT INTO sales.order_items VALUES (7, 6, 31, 1, 89999);
INSERT INTO sales.order_items VALUES (8, 6, 42, 2, 29999);
INSERT INTO sales.order_items VALUES (9, 7, 36, 2, 6999);
INSERT INTO sales.order_items VALUES (10, 7, 47, 3, 91999);
INSERT INTO sales.order_items VALUES (11, 8, 41, 3, 69999);
INSERT INTO sales.order_items VALUES (12, 9, 46, 1, 79999);
INSERT INTO sales.order_items VALUES (13, 9, 9, 2, 28999);
INSERT INTO sales.order_items VALUES (14, 10, 3, 2, 58999);
INSERT INTO sales.order_items VALUES (15, 11, 8, 3, 24999);
INSERT INTO sales.order_items VALUES (16, 12, 13, 1, 5999);
INSERT INTO sales.order_items VALUES (17, 12, 24, 2, 34999);
INSERT INTO sales.order_items VALUES (18, 13, 18, 2, 79999);
INSERT INTO sales.order_items VALUES (19, 14, 23, 3, 46999);
INSERT INTO sales.order_items VALUES (20, 14, 34, 1, 10999);
INSERT INTO sales.order_items VALUES (21, 15, 28, 1, 12999);
INSERT INTO sales.order_items VALUES (22, 15, 39, 2, 24999);
INSERT INTO sales.order_items VALUES (23, 16, 33, 2, 1299);
INSERT INTO sales.order_items VALUES (24, 17, 38, 3, 7999);
INSERT INTO sales.order_items VALUES (25, 18, 43, 1, 21999);
INSERT INTO sales.order_items VALUES (26, 18, 6, 2, 29999);
INSERT INTO sales.order_items VALUES (27, 19, 48, 2, 89999);
INSERT INTO sales.order_items VALUES (28, 20, 5, 3, 47999);
INSERT INTO sales.order_items VALUES (29, 21, 10, 1, 55999);
INSERT INTO sales.order_items VALUES (30, 21, 21, 2, 109999);
INSERT INTO sales.order_items VALUES (31, 21, 32, 3, 44999);
INSERT INTO sales.order_items VALUES (32, 22, 15, 2, 45999);
INSERT INTO sales.order_items VALUES (33, 23, 20, 3, 34999);
INSERT INTO sales.order_items VALUES (34, 24, 25, 1, 29999);
INSERT INTO sales.order_items VALUES (35, 24, 36, 2, 6999);
INSERT INTO sales.order_items VALUES (36, 25, 30, 2, 129999);
INSERT INTO sales.order_items VALUES (37, 26, 35, 3, 8999);
INSERT INTO sales.order_items VALUES (38, 27, 40, 1, 36999);
INSERT INTO sales.order_items VALUES (39, 27, 3, 2, 58999);
INSERT INTO sales.order_items VALUES (40, 28, 45, 2, 84999);
INSERT INTO sales.order_items VALUES (41, 28, 8, 3, 24999);
INSERT INTO sales.order_items VALUES (42, 29, 2, 3, 74999);
INSERT INTO sales.order_items VALUES (43, 30, 7, 1, 64999);
INSERT INTO sales.order_items VALUES (44, 30, 18, 2, 79999);
INSERT INTO sales.order_items VALUES (45, 31, 12, 2, 1999);
INSERT INTO sales.order_items VALUES (46, 32, 17, 3, 49999);
INSERT INTO sales.order_items VALUES (47, 33, 22, 1, 59999);
INSERT INTO sales.order_items VALUES (48, 33, 33, 2, 1299);
INSERT INTO sales.order_items VALUES (49, 34, 27, 2, 13999);
INSERT INTO sales.order_items VALUES (50, 35, 32, 3, 44999);
INSERT INTO sales.order_items VALUES (51, 35, 43, 1, 21999);
INSERT INTO sales.order_items VALUES (52, 36, 37, 1, 4999);
INSERT INTO sales.order_items VALUES (53, 36, 48, 2, 89999);
INSERT INTO sales.order_items VALUES (54, 37, 42, 2, 29999);
INSERT INTO sales.order_items VALUES (55, 38, 47, 3, 91999);
INSERT INTO sales.order_items VALUES (56, 39, 4, 1, 64999);
INSERT INTO sales.order_items VALUES (57, 39, 15, 2, 45999);
INSERT INTO sales.order_items VALUES (58, 40, 9, 2, 28999);
INSERT INTO sales.order_items VALUES (59, 41, 14, 3, 41999);
INSERT INTO sales.order_items VALUES (60, 42, 19, 1, 39999);
INSERT INTO sales.order_items VALUES (61, 42, 30, 2, 129999);
INSERT INTO sales.order_items VALUES (62, 42, 41, 3, 69999);
INSERT INTO sales.order_items VALUES (63, 43, 24, 2, 34999);
INSERT INTO sales.order_items VALUES (64, 44, 29, 3, 89999);
INSERT INTO sales.order_items VALUES (65, 45, 34, 1, 10999);
INSERT INTO sales.order_items VALUES (66, 45, 45, 2, 84999);
INSERT INTO sales.order_items VALUES (67, 46, 39, 2, 24999);
INSERT INTO sales.order_items VALUES (68, 47, 44, 3, 74999);
INSERT INTO sales.order_items VALUES (69, 48, 1, 1, 99999);
INSERT INTO sales.order_items VALUES (70, 48, 12, 2, 1999);
INSERT INTO sales.order_items VALUES (71, 49, 6, 2, 29999);
INSERT INTO sales.order_items VALUES (72, 49, 17, 3, 49999);
INSERT INTO sales.order_items VALUES (73, 50, 11, 3, 62999);
INSERT INTO sales.order_items VALUES (74, 51, 16, 1, 8999);
INSERT INTO sales.order_items VALUES (75, 51, 27, 2, 13999);
INSERT INTO sales.order_items VALUES (76, 52, 21, 2, 109999);

INSERT INTO sales.payments VALUES (1, 1, '2026-01-06', 'Credit Card', 'Paid', 59998);
INSERT INTO sales.payments VALUES (2, 2, '2026-01-09', 'Debit Card', 'Paid', 188997);
INSERT INTO sales.payments VALUES (3, 4, '2026-01-15', 'Cash', 'Paid', 219998);
INSERT INTO sales.payments VALUES (4, 6, '2026-01-21', 'Credit Card', 'Paid', 149997);
INSERT INTO sales.payments VALUES (5, 7, '2026-01-24', 'Debit Card', 'Paid', 289995);
INSERT INTO sales.payments VALUES (6, 8, '2026-01-27', 'Net Banking', 'Pending', 209997);
INSERT INTO sales.payments VALUES (7, 9, '2026-01-30', 'Cash', 'Paid', 137997);
INSERT INTO sales.payments VALUES (8, 10, '2026-02-02', 'UPI', 'Failed', 117998);
INSERT INTO sales.payments VALUES (9, 11, '2026-02-05', 'Credit Card', 'Paid', 74997);
INSERT INTO sales.payments VALUES (10, 12, '2026-02-08', 'UPI', 'Paid', 37998);
INSERT INTO sales.payments VALUES (11, 12, '2026-02-08', 'Credit Card', 'Paid', 37999);
INSERT INTO sales.payments VALUES (12, 14, '2026-02-14', 'Cash', 'Paid', 151996);
INSERT INTO sales.payments VALUES (13, 16, '2026-02-20', 'UPI', 'Paid', 1299);
INSERT INTO sales.payments VALUES (14, 16, '2026-02-20', 'Credit Card', 'Paid', 1299);
INSERT INTO sales.payments VALUES (15, 17, '2026-02-23', 'Debit Card', 'Paid', 23997);
INSERT INTO sales.payments VALUES (16, 18, '2026-02-26', 'Net Banking', 'Pending', 81997);
INSERT INTO sales.payments VALUES (17, 19, '2026-03-01', 'Cash', 'Paid', 179998);
INSERT INTO sales.payments VALUES (18, 20, '2026-03-04', 'UPI', 'Failed', 143997);
INSERT INTO sales.payments VALUES (19, 21, '2026-03-07', 'Credit Card', 'Paid', 410994);
INSERT INTO sales.payments VALUES (20, 22, '2026-03-10', 'Debit Card', 'Paid', 91998);
INSERT INTO sales.payments VALUES (21, 24, '2026-03-16', 'Cash', 'Paid', 43997);
INSERT INTO sales.payments VALUES (22, 26, '2026-03-22', 'Credit Card', 'Paid', 26997);
INSERT INTO sales.payments VALUES (23, 27, '2026-03-25', 'Debit Card', 'Paid', 154997);
INSERT INTO sales.payments VALUES (24, 28, '2026-03-28', 'Net Banking', 'Pending', 244995);
INSERT INTO sales.payments VALUES (25, 29, '2026-03-31', 'Cash', 'Paid', 224997);
INSERT INTO sales.payments VALUES (26, 30, '2026-04-03', 'UPI', 'Failed', 224997);
INSERT INTO sales.payments VALUES (27, 31, '2026-04-06', 'Credit Card', 'Paid', 3998);
INSERT INTO sales.payments VALUES (28, 32, '2026-04-09', 'UPI', 'Paid', 74998);
INSERT INTO sales.payments VALUES (29, 32, '2026-04-09', 'Credit Card', 'Paid', 74999);
INSERT INTO sales.payments VALUES (30, 34, '2026-04-15', 'Cash', 'Paid', 27998);
INSERT INTO sales.payments VALUES (31, 36, '2026-04-21', 'UPI', 'Paid', 92498);
INSERT INTO sales.payments VALUES (32, 36, '2026-04-21', 'Credit Card', 'Paid', 92499);
INSERT INTO sales.payments VALUES (33, 37, '2026-04-24', 'Debit Card', 'Paid', 59998);
INSERT INTO sales.payments VALUES (34, 38, '2026-04-27', 'Net Banking', 'Pending', 275997);
INSERT INTO sales.payments VALUES (35, 39, '2026-04-30', 'Cash', 'Paid', 156997);
INSERT INTO sales.payments VALUES (36, 40, '2026-05-03', 'UPI', 'Failed', 57998);
INSERT INTO sales.payments VALUES (37, 41, '2026-05-06', 'Credit Card', 'Paid', 125997);
INSERT INTO sales.payments VALUES (38, 42, '2026-05-09', 'Debit Card', 'Paid', 509994);
INSERT INTO sales.payments VALUES (39, 44, '2026-05-15', 'Cash', 'Paid', 269997);
INSERT INTO sales.payments VALUES (40, 46, '2026-05-21', 'Credit Card', 'Paid', 49998);
INSERT INTO sales.payments VALUES (41, 47, '2026-05-24', 'Debit Card', 'Paid', 224997);
INSERT INTO sales.payments VALUES (42, 48, '2026-05-27', 'Net Banking', 'Pending', 103997);
INSERT INTO sales.payments VALUES (43, 49, '2026-05-30', 'Cash', 'Paid', 209995);
INSERT INTO sales.payments VALUES (44, 50, '2026-06-02', 'UPI', 'Failed', 188997);
INSERT INTO sales.payments VALUES (45, 51, '2026-06-05', 'Credit Card', 'Paid', 36997);
INSERT INTO sales.payments VALUES (46, 52, '2026-06-08', 'UPI', 'Paid', 109999);
INSERT INTO sales.payments VALUES (47, 52, '2026-06-08', 'Credit Card', 'Paid', 109999);

INSERT INTO sales.shipments VALUES (1, 1, '2026-01-07', '2026-01-10', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (2, 2, '2026-01-10', '2026-01-13', 'DTDC', 'Delivered');
INSERT INTO sales.shipments VALUES (3, 4, '2026-01-16', NULL, 'XpressBees', 'In Transit');
INSERT INTO sales.shipments VALUES (4, 6, '2026-01-22', '2026-01-25', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (5, 6, '2026-01-23', '2026-01-26', 'DTDC', 'Delivered');
INSERT INTO sales.shipments VALUES (6, 7, '2026-01-25', '2026-01-28', 'DTDC', 'Delivered');
INSERT INTO sales.shipments VALUES (7, 9, '2026-01-31', NULL, 'XpressBees', 'Shipped');
INSERT INTO sales.shipments VALUES (8, 11, '2026-02-06', '2026-02-09', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (9, 12, '2026-02-09', '2026-02-12', 'DTDC', 'Delivered');
INSERT INTO sales.shipments VALUES (10, 12, '2026-02-10', '2026-02-13', 'Ecom Express', 'Delivered');
INSERT INTO sales.shipments VALUES (11, 14, '2026-02-15', NULL, 'XpressBees', 'In Transit');
INSERT INTO sales.shipments VALUES (12, 16, '2026-02-21', '2026-02-24', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (13, 17, '2026-02-24', '2026-02-27', 'DTDC', 'Delivered');
INSERT INTO sales.shipments VALUES (14, 19, '2026-03-02', NULL, 'XpressBees', 'Shipped');
INSERT INTO sales.shipments VALUES (15, 21, '2026-03-08', '2026-03-11', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (16, 22, '2026-03-11', '2026-03-14', 'DTDC', 'Delivered');
INSERT INTO sales.shipments VALUES (17, 24, '2026-03-17', NULL, 'XpressBees', 'In Transit');
INSERT INTO sales.shipments VALUES (18, 26, '2026-03-23', '2026-03-26', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (19, 27, '2026-03-26', NULL, 'DTDC', 'Returned');
INSERT INTO sales.shipments VALUES (20, 29, '2026-04-01', NULL, 'XpressBees', 'Shipped');
INSERT INTO sales.shipments VALUES (21, 31, '2026-04-07', '2026-04-10', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (22, 32, '2026-04-10', '2026-04-13', 'DTDC', 'Delivered');
INSERT INTO sales.shipments VALUES (23, 34, '2026-04-16', NULL, 'XpressBees', 'In Transit');
INSERT INTO sales.shipments VALUES (24, 36, '2026-04-22', NULL, 'Delhivery', 'Returned');
INSERT INTO sales.shipments VALUES (25, 37, '2026-04-25', '2026-04-28', 'DTDC', 'Delivered');
INSERT INTO sales.shipments VALUES (26, 39, '2026-05-01', NULL, 'XpressBees', 'Shipped');
INSERT INTO sales.shipments VALUES (27, 41, '2026-05-07', '2026-05-10', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (28, 42, '2026-05-10', '2026-05-13', 'DTDC', 'Delivered');
INSERT INTO sales.shipments VALUES (29, 42, '2026-05-11', '2026-05-14', 'Ecom Express', 'Delivered');
INSERT INTO sales.shipments VALUES (30, 44, '2026-05-16', NULL, 'XpressBees', 'In Transit');
INSERT INTO sales.shipments VALUES (31, 46, '2026-05-22', '2026-05-25', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (32, 47, '2026-05-25', '2026-05-28', 'DTDC', 'Delivered');
INSERT INTO sales.shipments VALUES (33, 49, '2026-05-31', NULL, 'XpressBees', 'Shipped');
INSERT INTO sales.shipments VALUES (34, 51, '2026-06-06', '2026-06-09', 'Delhivery', 'Delivered');
INSERT INTO sales.shipments VALUES (35, 52, '2026-06-09', '2026-06-12', 'DTDC', 'Delivered');


-- =====================================================================
-- 3. CATEGORY EXTENSION  (adds core.dim_category + category_id columns)
--   core.dim_category ........... NEW, 11 categories
--   products.products.category_id  NEW, filled from the existing text column products.category
--   core.dim_brand.category_id ..... NEW, the brand's MAIN category (where most of its products fall);
--                                  5 brands with no products (Motorola, Nothing, Panasonic,
--                                  Philips, Bose) are assigned by market focus
--   The text column products.category is kept, so earlier queries still work.
-- =====================================================================

CREATE TABLE core.dim_category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL
);

ALTER TABLE core.dim_brand      ADD COLUMN category_id INT REFERENCES core.dim_category(category_id);
ALTER TABLE products.products   ADD COLUMN category_id INT REFERENCES core.dim_category(category_id);

INSERT INTO core.dim_category VALUES (1, 'Laptop');
INSERT INTO core.dim_category VALUES (2, 'Mobile');
INSERT INTO core.dim_category VALUES (3, 'Tablet');
INSERT INTO core.dim_category VALUES (4, 'Smartwatch');
INSERT INTO core.dim_category VALUES (5, 'Headphones');
INSERT INTO core.dim_category VALUES (6, 'Camera');
INSERT INTO core.dim_category VALUES (7, 'Monitor');
INSERT INTO core.dim_category VALUES (8, 'TV');
INSERT INTO core.dim_category VALUES (9, 'Keyboard');
INSERT INTO core.dim_category VALUES (10, 'Mouse');
INSERT INTO core.dim_category VALUES (11, 'Accessory');

UPDATE products.products AS p
SET category_id = c.category_id
FROM core.dim_category c
WHERE c.category_name = p.category;

UPDATE core.dim_brand SET category_id = 1 WHERE brand_id IN (1, 3, 4, 5, 10, 11);  -- Laptop
UPDATE core.dim_brand SET category_id = 2 WHERE brand_id IN (2, 7, 8, 18, 19, 20, 21, 22);  -- Mobile
UPDATE core.dim_brand SET category_id = 3 WHERE brand_id IN (17);  -- Tablet
UPDATE core.dim_brand SET category_id = 5 WHERE brand_id IN (6, 12, 13, 25);  -- Headphones
UPDATE core.dim_brand SET category_id = 6 WHERE brand_id IN (14, 15);  -- Camera
UPDATE core.dim_brand SET category_id = 8 WHERE brand_id IN (9, 23, 24);  -- TV
UPDATE core.dim_brand SET category_id = 10 WHERE brand_id IN (16);  -- Mouse


-- =====================================================================
-- 4. WEB EVENTS EXTENSION  (added for the page-view self join)
--   web_events.page_views  - one row per page view, grouped by session_id
--   customer_id is NULLABLE (anonymous visitors); it links to customers.customers
--
--   Self join practice: pv1 JOIN pv2 ON same session_id AND pv1.view_timestamp < pv2.view_timestamp
--   Expected: 50 page views in 15 sessions; the self join returns 79 pairs
--   (a session with n views yields n*(n-1)/2 pairs; single-view sessions yield none)
-- =====================================================================

DROP SCHEMA IF EXISTS web_events CASCADE;
CREATE SCHEMA web_events;

CREATE TABLE web_events.page_views (
    page_view_id   INT PRIMARY KEY,
    session_id     VARCHAR(20) NOT NULL,
    customer_id    INT REFERENCES customers.customers(customer_id),   -- NULL = anonymous
    page_url       VARCHAR(200) NOT NULL,
    view_timestamp TIMESTAMP NOT NULL
);

INSERT INTO web_events.page_views VALUES (1, 'S1001', 17, '/home', '2026-09-03 23:14:00');
INSERT INTO web_events.page_views VALUES (2, 'S1001', 17, '/products', '2026-09-03 23:14:43');
INSERT INTO web_events.page_views VALUES (3, 'S1001', 17, '/products/laptops', '2026-09-03 23:17:59');
INSERT INTO web_events.page_views VALUES (4, 'S1001', 17, '/product/detail', '2026-09-03 23:18:33');
INSERT INTO web_events.page_views VALUES (5, 'S1001', 17, '/cart', '2026-09-03 23:21:34');
INSERT INTO web_events.page_views VALUES (6, 'S1001', 17, '/checkout', '2026-09-03 23:24:51');
INSERT INTO web_events.page_views VALUES (7, 'S1002', 27, '/products', '2026-09-01 17:01:00');
INSERT INTO web_events.page_views VALUES (8, 'S1002', 27, '/product/detail', '2026-09-01 17:01:31');
INSERT INTO web_events.page_views VALUES (9, 'S1002', 27, '/cart', '2026-09-01 17:02:34');
INSERT INTO web_events.page_views VALUES (10, 'S1002', 27, '/checkout', '2026-09-01 17:03:41');
INSERT INTO web_events.page_views VALUES (11, 'S1003', 45, '/home', '2026-09-08 07:44:00');
INSERT INTO web_events.page_views VALUES (12, 'S1003', 45, '/products', '2026-09-08 07:46:27');
INSERT INTO web_events.page_views VALUES (13, 'S1003', 45, '/products/laptops', '2026-09-08 07:48:22');
INSERT INTO web_events.page_views VALUES (14, 'S1004', 51, '/products', '2026-09-01 10:48:00');
INSERT INTO web_events.page_views VALUES (15, 'S1004', 51, '/product/detail', '2026-09-01 10:51:34');
INSERT INTO web_events.page_views VALUES (16, 'S1004', 51, '/cart', '2026-09-01 10:52:22');
INSERT INTO web_events.page_views VALUES (17, 'S1004', 51, '/checkout', '2026-09-01 10:55:28');
INSERT INTO web_events.page_views VALUES (18, 'S1004', 51, '/order-confirmation', '2026-09-01 10:57:24');
INSERT INTO web_events.page_views VALUES (19, 'S1005', 48, '/home', '2026-09-04 23:06:00');
INSERT INTO web_events.page_views VALUES (20, 'S1005', 48, '/products/mobiles', '2026-09-04 23:06:31');
INSERT INTO web_events.page_views VALUES (21, 'S1006', 22, '/home', '2026-09-07 19:16:00');
INSERT INTO web_events.page_views VALUES (22, 'S1007', 34, '/home', '2026-09-02 16:59:00');
INSERT INTO web_events.page_views VALUES (23, 'S1008', 53, '/home', '2026-09-08 01:39:00');
INSERT INTO web_events.page_views VALUES (24, 'S1008', 53, '/products', '2026-09-08 01:42:54');
INSERT INTO web_events.page_views VALUES (25, 'S1008', 53, '/products/laptops', '2026-09-08 01:46:42');
INSERT INTO web_events.page_views VALUES (26, 'S1008', 53, '/product/detail', '2026-09-08 01:48:22');
INSERT INTO web_events.page_views VALUES (27, 'S1009', 2, '/home', '2026-09-08 10:14:00');
INSERT INTO web_events.page_views VALUES (28, 'S1009', 2, '/search', '2026-09-08 10:17:25');
INSERT INTO web_events.page_views VALUES (29, 'S1009', 2, '/product/detail', '2026-09-08 10:18:47');
INSERT INTO web_events.page_views VALUES (30, 'S1010', NULL, '/home', '2026-09-05 10:17:00');
INSERT INTO web_events.page_views VALUES (31, 'S1010', NULL, '/products', '2026-09-05 10:19:04');
INSERT INTO web_events.page_views VALUES (32, 'S1010', NULL, '/products/laptops', '2026-09-05 10:21:54');
INSERT INTO web_events.page_views VALUES (33, 'S1010', NULL, '/product/detail', '2026-09-05 10:25:35');
INSERT INTO web_events.page_views VALUES (34, 'S1010', NULL, '/cart', '2026-09-05 10:27:16');
INSERT INTO web_events.page_views VALUES (35, 'S1010', NULL, '/checkout', '2026-09-05 10:28:05');
INSERT INTO web_events.page_views VALUES (36, 'S1011', 17, '/products', '2026-09-08 20:59:00');
INSERT INTO web_events.page_views VALUES (37, 'S1011', 17, '/product/detail', '2026-09-08 21:02:02');
INSERT INTO web_events.page_views VALUES (38, 'S1011', 17, '/cart', '2026-09-08 21:04:55');
INSERT INTO web_events.page_views VALUES (39, 'S1011', 17, '/checkout', '2026-09-08 21:05:21');
INSERT INTO web_events.page_views VALUES (40, 'S1011', 17, '/order-confirmation', '2026-09-08 21:08:04');
INSERT INTO web_events.page_views VALUES (41, 'S1012', 15, '/home', '2026-09-03 02:29:00');
INSERT INTO web_events.page_views VALUES (42, 'S1012', 15, '/search', '2026-09-03 02:30:45');
INSERT INTO web_events.page_views VALUES (43, 'S1013', 14, '/products', '2026-09-08 16:20:00');
INSERT INTO web_events.page_views VALUES (44, 'S1013', 14, '/product/detail', '2026-09-08 16:23:43');
INSERT INTO web_events.page_views VALUES (45, 'S1013', 14, '/cart', '2026-09-08 16:27:07');
INSERT INTO web_events.page_views VALUES (46, 'S1013', 14, '/checkout', '2026-09-08 16:30:33');
INSERT INTO web_events.page_views VALUES (47, 'S1014', NULL, '/home', '2026-09-04 17:25:00');
INSERT INTO web_events.page_views VALUES (48, 'S1014', NULL, '/search', '2026-09-04 17:26:16');
INSERT INTO web_events.page_views VALUES (49, 'S1014', NULL, '/product/detail', '2026-09-04 17:26:40');
INSERT INTO web_events.page_views VALUES (50, 'S1015', NULL, '/home', '2026-09-04 17:13:00');
