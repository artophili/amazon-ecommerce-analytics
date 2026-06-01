-- Query 1: Month-over-Month Revenue Growth Performance
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', date) AS sales_month,
        SUM(CASE WHEN status NOT IN ('Cancelled', 'Rejected', 'Returned') THEN amount ELSE 0 END) AS net_revenue
    FROM fact_amazon_sales
    GROUP BY DATE_TRUNC('month', date)
)
SELECT 
    TO_CHAR(sales_month, 'YYYY-MM') AS month,
    net_revenue AS current_month_revenue,
    LAG(net_revenue, 1) OVER (ORDER BY sales_month) AS previous_month_revenue,
    ROUND(
        (net_revenue - LAG(net_revenue, 1) OVER (ORDER BY sales_month)) * 100.0 / 
        LAG(net_revenue, 1) OVER (ORDER BY sales_month), 2
    ) AS mom_growth_percentage
FROM monthly_revenue;

-- Query 2: Product Category Ranking & Cumulative Revenue Share
WITH category_revenue AS (
    SELECT 
        p.category,
        SUM(f.amount) AS total_gross_revenue
    FROM fact_amazon_sales f
    JOIN dim_product p ON f.sku = p.sku
    GROUP BY p.category
),
total_warehouse_revenue AS (
    SELECT SUM(total_gross_revenue) AS global_revenue FROM category_revenue
)
SELECT 
    cr.category,
    cr.total_gross_revenue,
    ROUND(cr.total_gross_revenue * 100.0 / twr.global_revenue, 2) AS revenue_contribution_percentage,
    ROUND(
        SUM(cr.total_gross_revenue) OVER (ORDER BY cr.total_gross_revenue DESC) * 100.0 / 
        twr.global_revenue, 2
    ) AS cumulative_revenue_percentage
FROM category_revenue cr, total_warehouse_revenue twr
ORDER BY cr.total_gross_revenue DESC;

--Identifying High-Risk Fulfillment Centers
SELECT 
    fulfilment,
    courier_status,
    COUNT(order_id) AS total_shipments,
    SUM(qty) AS total_units_handled,
    ROUND(
        COUNT(CASE WHEN status IN ('Cancelled', 'Returned') THEN 1 END) * 100.0 / 
        COUNT(*), 2
    ) AS line_item_failure_rate_percentage
FROM fact_amazon_sales
GROUP BY fulfilment, courier_status
ORDER BY total_shipments DESC;
