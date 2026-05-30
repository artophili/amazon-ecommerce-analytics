-- Query 1: Financial & Operational Summary
SELECT 
    COUNT(DISTINCT order_id) AS total_orders,
    
    -- Gross Merchandise Value (Initial revenue)
    SUM(amount) AS gross_merchandise_value_inr,
    
    -- Net Revenue (Actual realized money from successful deliveries)
    SUM(CASE WHEN status NOT IN ('Cancelled', 'Rejected', 'Returned') THEN amount ELSE 0 END) AS net_revenue_inr,
    
    -- Average Order Value for successful transactions
    ROUND(
        SUM(CASE WHEN status NOT IN ('Cancelled', 'Rejected', 'Returned') THEN amount ELSE 0 END) / 
        COUNT(DISTINCT CASE WHEN status NOT IN ('Cancelled', 'Rejected', 'Returned') THEN order_id END), 2
    ) AS successful_average_order_value_aov,
    
    -- Order Defect Rate (Percentage of orders lost to cancellations or returns)
    ROUND(
        COUNT(DISTINCT CASE WHEN status IN ('Cancelled', 'Rejected', 'Returned') THEN order_id END) * 100.0 / 
        COUNT(DISTINCT order_id), 2
    ) AS order_defect_rate_percentage
FROM fact_amazon_sales;


-- Query 2: B2B vs B2C
SELECT 
    CASE WHEN b2b = TRUE THEN 'Wholesale B2B' ELSE 'Retail B2C' END AS customer_segment,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(qty) AS total_units_sold,
    SUM(amount) AS total_revenue,
    ROUND(SUM(amount) / SUM(qty), 2) AS average_price_per_unit,
    ROUND(SUM(amount) / COUNT(DISTINCT order_id), 2) AS average_order_value
FROM fact_amazon_sales
GROUP BY b2b;

-- Query 3: State-by-State Performance & Courier Risk
SELECT 
    g.state,
    COUNT(DISTINCT f.order_id) AS total_orders,
    SUM(f.amount) AS total_gross_revenue,
    
    -- Regional Cancellation Rate
    ROUND(
        SUM(CASE WHEN f.status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / 
        COUNT(*), 2
    ) AS cancellation_rate_percentage
FROM fact_amazon_sales f
JOIN dim_geography g ON f.location_id = g.location_id
GROUP BY g.state
ORDER BY total_gross_revenue DESC
LIMIT 10;