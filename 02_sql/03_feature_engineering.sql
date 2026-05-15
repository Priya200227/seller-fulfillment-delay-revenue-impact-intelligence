CREATE TABLE order_delivery_features AS
SELECT
    order_id,
    customer_id,
    order_status,

    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    
       -- Approval delay
    TIMESTAMPDIFF(
        HOUR,
        order_purchase_timestamp,
        order_approved_at
    ) AS approval_delay_hours,
    
        -- Seller processing delay
    TIMESTAMPDIFF(
        DAY,
        order_approved_at,
        order_delivered_carrier_date
    ) AS seller_processing_days,
    
       -- Actual delivery duration
    TIMESTAMPDIFF(
        DAY,
        order_purchase_timestamp,
        order_delivered_customer_date
    ) AS actual_delivery_days,
    
		-- Estimated delivery duration
    TIMESTAMPDIFF(
        DAY,
        order_purchase_timestamp,
        order_estimated_delivery_date
    ) AS estimated_delivery_days,
    
     -- Delivery deviation
    DATEDIFF(
        order_delivered_customer_date,
        order_estimated_delivery_date
    ) AS delivery_delay_days,

    -- Late delivery flag
    CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date
        THEN 1
        ELSE 0
    END AS is_late_delivery
FROM orders_operational_clean;
    
    
-- =====================================
-- FINANCIAL FEATURES
-- =====================================
CREATE TABLE order_value_features AS
SELECT
    oi.order_id,
    SUM(oi.price) AS total_order_value,
    SUM(oi.freight_value) AS total_freight_value,
    COUNT(DISTINCT oi.product_id) AS total_products,
    COUNT(DISTINCT oi.seller_id) AS total_sellers
FROM order_items oi
GROUP BY oi.order_id;


-- ==================================
-- JOINING BOTH TABLES
-- ==================================

CREATE TABLE operational_base_table AS
SELECT
    odf.*,
    ovf.total_order_value,
    ovf.total_freight_value,
    ovf.total_products,
    ovf.total_sellers
FROM order_delivery_features odf
LEFT JOIN order_value_features ovf
    ON odf.order_id = ovf.order_id;
    
    
-- VALIDATION
SELECT * FROM operational_base_table
LIMIT 10;