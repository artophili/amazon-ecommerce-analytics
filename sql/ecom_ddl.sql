CREATE TABLE staging_amazon_sales (
    order_id VARCHAR(50),
    date DATE,
    status VARCHAR(50),
    fulfilment VARCHAR(50),
    sales_channel VARCHAR(50),
    ship_service_level VARCHAR(50),
    category VARCHAR(50),
    size VARCHAR(20),
    courier_status VARCHAR(50),
    qty INT,
    currency VARCHAR(10),
    amount DECIMAL(10,2),
    ship_city VARCHAR(100),
    ship_state VARCHAR(100),
    ship_postal_code VARCHAR(20),
    ship_country VARCHAR(50),
    b2b BOOLEAN,
    fulfilled_by VARCHAR(50),
    sku VARCHAR(50)
);

SELECT * FROM staging_amazon_sales;

CREATE TABLE dim_geography (
    location_id SERIAL PRIMARY KEY,
    postal_code VARCHAR(10) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    country VARCHAR(50) DEFAULT 'India'
);

CREATE TABLE dim_product (
    sku VARCHAR(50) PRIMARY KEY,
    category VARCHAR(100) NOT NULL,
    size VARCHAR(10) NOT NULL
);

-- 3. Creating Fact Table: Sales Transactions
CREATE TABLE fact_amazon_sales (
    order_id VARCHAR(50),
    sku VARCHAR(50),
    date DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    fulfilment VARCHAR(30) NOT NULL,
    sales_channel VARCHAR(50) DEFAULT 'Amazon.in',
    ship_service_level VARCHAR(30),
    courier_status VARCHAR(30) DEFAULT 'Unknown',
    qty INT DEFAULT 0,
    currency VARCHAR(10) DEFAULT 'INR',
    amount DECIMAL(12, 2) DEFAULT 0.00,
    location_id INT, -- Keeps track of the foreign key link
	postal_code VARCHAR(10),
    b2b BOOLEAN DEFAULT FALSE,
    fulfilled_by VARCHAR(30),
    PRIMARY KEY (order_id, sku),
    FOREIGN KEY (location_id) REFERENCES dim_geography(location_id),
    FOREIGN KEY (sku) REFERENCES dim_product(sku)
);

-- 4. Create Performance Indexes for Analytical Queries
CREATE INDEX idx_sales_date ON fact_amazon_sales(date);
CREATE INDEX idx_sales_status ON fact_amazon_sales(status);

-- 1. Populating Geography Dimension
INSERT INTO dim_geography (postal_code, city, state, country)
SELECT DISTINCT ship_postal_code, ship_city, ship_state, ship_country
FROM staging_amazon_sales;

-- 2. Populating Product Dimension
INSERT INTO dim_product (sku, category, size)
SELECT DISTINCT sku, category, size
FROM staging_amazon_sales;

-- 3. Populating your Fact Table
INSERT INTO fact_amazon_sales (
    order_id, date, status, fulfilment, sales_channel, 
    ship_service_level, courier_status, qty, currency, 
    amount, postal_code, b2b, fulfilled_by, sku
)
SELECT 
    order_id, date, status, fulfilment, sales_channel, 
    ship_service_level, courier_status, qty, currency, 
    amount, ship_postal_code, b2b, fulfilled_by, sku
FROM staging_amazon_sales;

-- 4. Cleaning up the staging table
DROP TABLE staging_amazon_sales;


DROP TABLE IF EXISTS fact_amazon_sales CASCADE;
DROP TABLE IF EXISTS dim_geography CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;

--Checking if same order_id appears multiple times but has different categories, sizes, or quantities
SELECT order_id, COUNT(DISTINCT category) as unique_categories_ordered
FROM staging_amazon_sales
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY unique_categories_ordered DESC;

--If the exact same order_id has the exact same category, size, quantity, and amount duplicated across multiple rows
SELECT order_id, category, size, qty, amount, COUNT(*) 
FROM staging_amazon_sales
GROUP BY order_id, category, size, qty, amount
HAVING COUNT(*) > 1;

--Deduplicating the Staging Layer
CREATE TABLE staging_amazon_sales_clean AS
SELECT DISTINCT * FROM staging_amazon_sales;

DROP TABLE staging_amazon_sales;

ALTER TABLE staging_amazon_sales_clean RENAME TO staging_amazon_sales;


--Re-Initializing the Clean Schema Tables
DROP TABLE IF EXISTS fact_amazon_sales CASCADE;
DROP TABLE IF EXISTS dim_geography CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;

CREATE TABLE dim_geography (
    location_id SERIAL PRIMARY KEY,
    postal_code VARCHAR(20) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    country VARCHAR(50) DEFAULT 'India'
);

CREATE TABLE dim_product (
    sku VARCHAR(50) PRIMARY KEY,
    category VARCHAR(100) NOT NULL,
    size VARCHAR(20) NOT NULL
);

CREATE TABLE fact_amazon_sales (
    order_id VARCHAR(50),
    sku VARCHAR(50),
    date DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    fulfilment VARCHAR(30) NOT NULL,
    sales_channel VARCHAR(50),
    ship_service_level VARCHAR(30),
    courier_status VARCHAR(30),
    qty INT,
    currency VARCHAR(10),
    amount DECIMAL(12, 2),
    location_id INT,
    b2b BOOLEAN,
    fulfilled_by VARCHAR(30),
    
    PRIMARY KEY (order_id, sku), 
    FOREIGN KEY (location_id) REFERENCES dim_geography(location_id),
    FOREIGN KEY (sku) REFERENCES dim_product(sku)
);

INSERT INTO dim_geography (postal_code, city, state, country)
SELECT DISTINCT ship_postal_code, ship_city, ship_state, ship_country
FROM staging_amazon_sales;

SELECT * FROM dim_geography;

INSERT INTO dim_product (sku, category, size)
SELECT DISTINCT 
    TRIM(sku),
    TRIM(category),
    TRIM(size)
FROM staging_amazon_sales;

SELECT * FROM dim_product;

INSERT INTO fact_amazon_sales (
    order_id, sku, date, status, fulfilment, sales_channel, 
    ship_service_level, courier_status, qty, currency, amount, 
    location_id, b2b, fulfilled_by
)
SELECT 
    s.order_id,
    s.sku,
    s.date,
    s.status,
    s.fulfilment,
    s.sales_channel,
    s.ship_service_level,
    s.courier_status,
    s.qty,
    s.currency,
    s.amount,
    g.location_id, -- Maps back to our auto-incremented surrogate key
    s.b2b,
    s.fulfilled_by
FROM staging_amazon_sales s
JOIN dim_geography g 
    ON s.ship_postal_code = g.postal_code 
    AND s.ship_city = g.city 
    AND s.ship_state = g.state;

TRUNCATE TABLE fact_amazon_sales;

INSERT INTO fact_amazon_sales (
    order_id, sku, date, status, fulfilment, sales_channel, 
    ship_service_level, courier_status, qty, currency, amount, 
    location_id, b2b, fulfilled_by
)
SELECT 
    s.order_id,
    s.sku,
    s.date,
    MAX(s.status) AS status,               -- Picks the most advanced status 
    MAX(s.fulfilment) AS fulfilment,
    MAX(s.sales_channel) AS sales_channel,
    MAX(s.ship_service_level) AS ship_service_level,
    MAX(s.courier_status) AS courier_status,
    SUM(s.qty) AS qty,                     -- Adds quantities together perfectly
    MAX(s.currency) AS currency,
    SUM(s.amount) AS amount,               -- Sums up total revenue across both lines
    g.location_id,
    MAX(s.b2b::int)::boolean AS b2b,       -- Resolves boolean flags safely
    MAX(s.fulfilled_by) AS fulfilled_by
FROM staging_amazon_sales s
JOIN dim_geography g 
    ON s.ship_postal_code = g.postal_code 
    AND s.ship_city = g.city 
    AND s.ship_state = g.state
GROUP BY 
    s.order_id,
    s.sku,
    s.date,
    g.location_id;

SELECT * FROM fact_amazon_sales;

SELECT 'Geography Dimension Table' as table_name, COUNT(*) FROM dim_geography
UNION ALL
SELECT 'Product Dimension Table', COUNT(*) FROM dim_product
UNION ALL
SELECT 'Sales Fact Transaction Table', COUNT(*) FROM fact_amazon_sales;