-- Olist E-Commerce: representative MySQL analysis queries
-- Source: Brazilian E-Commerce Public Dataset by Olist
-- Reconstructed shareable queries matching the implemented portfolio analysis.
-- Existing imported CSV tables are expected in schema olist_ecommerce.

USE olist_ecommerce;

-- 1. Validate input row counts
SELECT COUNT(*) AS seller_rows FROM olist_sellers_dataset;
SELECT COUNT(*) AS order_item_rows FROM olist_order_items_dataset;
SELECT COUNT(*) AS order_rows FROM olist_orders_dataset;
SELECT COUNT(*) AS customer_rows FROM olist_customers_dataset;

-- 2. Item sales and revenue share by seller state
WITH state_sales AS (
    SELECT
        s.seller_state,
        COUNT(*) AS item_rows,
        COUNT(DISTINCT oi.seller_id) AS active_sellers,
        SUM(oi.price) AS item_sales
    FROM olist_order_items_dataset AS oi
    INNER JOIN olist_sellers_dataset AS s
        ON oi.seller_id = s.seller_id
    GROUP BY s.seller_state
)
SELECT
    seller_state,
    item_rows,
    active_sellers,
    ROUND(item_sales, 2) AS item_sales_brl,
    ROUND(100.0 * item_sales / SUM(item_sales) OVER (), 2) AS item_sales_share_pct
FROM state_sales
ORDER BY item_sales DESC;

-- 3. Sales per seller (at least 30 distinct active sellers by state)
SELECT
    s.seller_state,
    COUNT(DISTINCT oi.seller_id) AS active_sellers,
    ROUND(SUM(oi.price), 2) AS item_sales_brl,
    ROUND(SUM(oi.price) / COUNT(DISTINCT oi.seller_id), 2) AS sales_per_seller_brl
FROM olist_order_items_dataset AS oi
INNER JOIN olist_sellers_dataset AS s
    ON oi.seller_id = s.seller_id
GROUP BY s.seller_state
HAVING COUNT(DISTINCT oi.seller_id) >= 30
ORDER BY sales_per_seller_brl DESC;

-- 4. Delivery analytics VIEW imported into Power BI
-- Important: compares TIMESTAMPS, not date-only delivery commitments.
CREATE OR REPLACE VIEW vw_delivery_performance AS
SELECT
    o.order_id,
    c.customer_state,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    DATEDIFF(
        o.order_delivered_customer_date,
        o.order_purchase_timestamp
    ) AS delivery_days,
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
        THEN 1 ELSE 0
    END AS is_on_time
FROM olist_orders_dataset AS o
INNER JOIN olist_customers_dataset AS c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL;

-- 5. Validate delivery KPIs
SELECT
    COUNT(*) AS delivered_orders,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    ROUND(100.0 * AVG(is_on_time), 2) AS on_time_rate_pct
FROM vw_delivery_performance;

-- 6. Regional delivery performance (minimum 100 eligible deliveries)
SELECT
    customer_state,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    ROUND(100.0 * AVG(is_on_time), 2) AS on_time_rate_pct
FROM vw_delivery_performance
GROUP BY customer_state
HAVING COUNT(*) >= 100
ORDER BY on_time_rate_pct ASC;
