-- ============================================================
-- Olist Brazilian E-Commerce: MySQL setup (tables + import)
-- ============================================================
-- BEFORE RUNNING:
-- 1. Replace every 'E:/olist_data/' below with the folder where you extracted the CSVs
--    (use forward slashes, even on Windows).
-- 2. Enable local file loading (run once):
--       SET GLOBAL local_infile = 1;
--    In MySQL Workbench: Edit Connection > Advanced > Others, add:  OPT_LOCAL_INFILE=1
--    then reconnect.
-- ============================================================
drop database if exists olist_project;
CREATE DATABASE IF NOT EXISTS olist_project;
USE olist_project;

-- ---------- 1. TABLES ----------

CREATE TABLE customers (
  customer_id              VARCHAR(40) PRIMARY KEY,
  customer_unique_id       VARCHAR(40),
  customer_zip_code_prefix VARCHAR(10),
  customer_city            VARCHAR(100),
  customer_state           CHAR(2)
);

CREATE TABLE sellers (
  seller_id              VARCHAR(40) PRIMARY KEY,
  seller_zip_code_prefix VARCHAR(10),
  seller_city            VARCHAR(100),
  seller_state           CHAR(2)
);

CREATE TABLE products (
  product_id                 VARCHAR(40) PRIMARY KEY,
  product_category_name      VARCHAR(100),
  product_name_lenght        INT,
  product_description_lenght INT,
  product_photos_qty         INT,
  product_weight_g           INT,
  product_length_cm          INT,
  product_height_cm          INT,
  product_width_cm           INT
);

CREATE TABLE product_category_translation (
  product_category_name         VARCHAR(100) PRIMARY KEY,
  product_category_name_english VARCHAR(100)
);

CREATE TABLE orders (
  order_id                      VARCHAR(40) PRIMARY KEY,
  customer_id                   VARCHAR(40),
  order_status                  VARCHAR(20),
  order_purchase_timestamp      DATETIME,
  order_approved_at             DATETIME,
  order_delivered_carrier_date  DATETIME,
  order_delivered_customer_date DATETIME,
  order_estimated_delivery_date DATETIME
);

CREATE TABLE order_items (
  order_id            VARCHAR(40),
  order_item_id       INT,
  product_id          VARCHAR(40),
  seller_id           VARCHAR(40),
  shipping_limit_date DATETIME,
  price               DECIMAL(10,2),
  freight_value       DECIMAL(10,2),
  PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE order_payments (
  order_id             VARCHAR(40),
  payment_sequential   INT,
  payment_type         VARCHAR(30),
  payment_installments INT,
  payment_value        DECIMAL(10,2),
  PRIMARY KEY (order_id, payment_sequential)
);

-- review_id is NOT unique in this dataset, so no primary key here
CREATE TABLE order_reviews (
  review_id               VARCHAR(40),
  order_id                VARCHAR(40),
  review_score            INT,
  review_comment_title    VARCHAR(255),
  review_comment_message  TEXT,
  review_creation_date    DATETIME,
  review_answer_timestamp DATETIME
);

CREATE TABLE geolocation (
  geolocation_zip_code_prefix VARCHAR(10),
  geolocation_lat             DECIMAL(18,15),
  geolocation_lng             DECIMAL(18,15),
  geolocation_city            VARCHAR(100),
  geolocation_state           CHAR(2)
);

-- ---------- 2. IMPORT ----------
-- Empty values are converted to NULL with NULLIF.
-- If a file has Windows line endings and rows look wrong, change '\n' to '\r\n'.

LOAD DATA LOCAL INFILE 'E:/olist_data/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'E:/olist_data/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'E:/olist_data/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_id, @cat, @nl, @dl, @pq, @w, @l, @h, @wd)
SET product_category_name      = NULLIF(@cat,''),
    product_name_lenght        = NULLIF(@nl,''),
    product_description_lenght = NULLIF(@dl,''),
    product_photos_qty         = NULLIF(@pq,''),
    product_weight_g           = NULLIF(@w,''),
    product_length_cm          = NULLIF(@l,''),
    product_height_cm          = NULLIF(@h,''),
    product_width_cm           = NULLIF(@wd,'');

LOAD DATA LOCAL INFILE 'E:/olist_data/product_category_name_translation.csv'
INTO TABLE product_category_translation
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'E:/olist_data/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer_id, order_status, @purchase, @approved, @carrier, @delivered, @estimated)
SET order_purchase_timestamp      = NULLIF(@purchase,''),
    order_approved_at             = NULLIF(@approved,''),
    order_delivered_carrier_date  = NULLIF(@carrier,''),
    order_delivered_customer_date = NULLIF(@delivered,''),
    order_estimated_delivery_date = NULLIF(@estimated,'');

LOAD DATA LOCAL INFILE 'E:/olist_data/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'E:/olist_data/olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'E:/olist_data/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(review_id, order_id, review_score, @title, @message, @created, @answered)
SET review_comment_title    = NULLIF(@title,''),
    review_comment_message  = NULLIF(@message,''),
    review_creation_date    = NULLIF(@created,''),
    review_answer_timestamp = NULLIF(@answered,'');

LOAD DATA LOCAL INFILE 'E:/olist_data/olist_geolocation_dataset.csv'
INTO TABLE geolocation
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ---------- 3. VERIFY (compare with expected counts) ----------

SELECT 'customers'      AS tbl, COUNT(*) AS row_count FROM customers      UNION ALL  -- ~99,441
SELECT 'sellers',                COUNT(*)              FROM sellers        UNION ALL  -- ~3,095
SELECT 'products',               COUNT(*)              FROM products       UNION ALL  -- ~32,951
SELECT 'translation',            COUNT(*)              FROM product_category_translation UNION ALL  -- ~71
SELECT 'orders',                 COUNT(*)              FROM orders         UNION ALL  -- ~99,441
SELECT 'order_items',            COUNT(*)              FROM order_items    UNION ALL  -- ~112,650
SELECT 'order_payments',         COUNT(*)              FROM order_payments UNION ALL  -- ~103,886
SELECT 'order_reviews',          COUNT(*)              FROM order_reviews  UNION ALL  -- ~99,224
SELECT 'geolocation',            COUNT(*)              FROM geolocation;              -- ~1,000,163

-- ---------- 4. QUICK CHECKS ----------

SELECT * FROM orders LIMIT 10;

-- Rows with NULL delivery date (undelivered/cancelled orders) are expected
SELECT order_status, COUNT(*) AS orders,
       SUM(order_delivered_customer_date IS NULL) AS no_delivery_date
FROM orders
GROUP BY order_status;
