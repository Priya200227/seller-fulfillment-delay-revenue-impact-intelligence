SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL
SELECT 'category_translation', COUNT(*) FROM category_translation;

-- ==========================
-- DUPLICATE VALIDATION
-- ==========================

SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;


-- DUPLICATE CUSTOMERS
SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- DUPLICATE SELLERS
SELECT
    seller_id,
    COUNT(*) AS duplicate_count
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;


-- =================================
-- NULL/MISSING VALUE VALIDATION
-- =================================

SELECT
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS missing_approval,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS missing_carrier_delivery,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS missing_customer_delivery
FROM orders;


-- ============================
-- ORPHAN RECORD VALIDATION
-- ============================

-- Orders without Customers
SELECT COUNT(*) AS orphan_orders
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Order Items without Orders
SELECT COUNT(*) AS orphan_order_items
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Order Items without Sellers
SELECT COUNT(*) AS orphan_seller_links
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


-- ==============================
-- TEMPORAL ANOMALY VALIDATION
-- ==============================

-- Delivered Before Purchase
SELECT * FROM orders
WHERE order_delivered_customer_date < order_purchase_timestamp;


-- Carrier Pickup Before Approval
SELECT * FROM orders
WHERE order_delivered_carrier_date < order_approved_at;


-- Estimated Delivery Before Purchase
SELECT * FROM orders
WHERE order_estimated_delivery_date < order_purchase_timestamp;



-- ================================
-- STATUS CONSISTENCY VALIDATION
-- =================================

SELECT * FROM orders
WHERE order_status = 'canceled'
AND order_delivered_customer_date IS NOT NULL;


-- ===========================
-- EXTREME VALUE VALIDATION
-- ===========================

SELECT * FROM order_items
WHERE freight_value < 0;

SELECT * FROM order_items
WHERE price <= 0;
