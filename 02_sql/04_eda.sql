-- =========================================
-- DELIVERY PERFORMANCE DISTRIBUTION
-- =========================================

SELECT delivery_delay_days,
		COUNT(*) as total_orders
FROM operational_base_table
GROUP BY delivery_delay_days
ORDER BY delivery_delay_days;


-- ====================================
-- SUMMARY STATUS
-- ====================================
SELECT
    ROUND(AVG(delivery_delay_days), 2) AS avg_delay,
    MIN(delivery_delay_days) AS min_delay,
    MAX(delivery_delay_days) AS max_delay,
    ROUND(STDDEV(delivery_delay_days), 2) AS std_delay
FROM operational_base_table;


-- ======================================
-- LATE DELIVERY RATE
-- ======================================
SELECT
    is_late_delivery,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),2) AS percentage
FROM operational_base_table
GROUP BY is_late_delivery;


-- ========================================
-- SELLER PROCESSING ANALYSIS
-- ========================================
SELECT
    seller_processing_days,
    COUNT(*) AS total_orders
FROM operational_base_table
GROUP BY seller_processing_days
ORDER BY seller_processing_days DESC;
 
 
 
 -- =========================================
 -- REVENUE VS DELAY
 -- =========================================
 SELECT
    CASE
        WHEN delivery_delay_days <= 0 THEN 'On Time / Early'
        WHEN delivery_delay_days BETWEEN 1 AND 3 THEN '1-3 Days Late'
        WHEN delivery_delay_days BETWEEN 4 AND 7 THEN '4-7 Days Late'
        ELSE '8+ Days Late'
    END AS delay_bucket,
    COUNT(*) AS total_orders,
    ROUND(SUM(total_order_value), 2) AS total_revenue,
    ROUND(AVG(total_order_value), 2) AS avg_order_value
FROM operational_base_table
GROUP BY delay_bucket
ORDER BY total_revenue DESC;


-- =====================================
-- HIGH RISK SELLERS
-- ======================================
SELECT
    oi.seller_id,
    COUNT(DISTINCT obt.order_id) AS total_orders,
    ROUND(AVG(obt.delivery_delay_days), 2) AS avg_delay,
    ROUND(SUM(obt.is_late_delivery) * 100.0 / COUNT(*),2) AS late_delivery_rate,
    ROUND(SUM(obt.total_order_value), 2) AS total_revenue
FROM operational_base_table obt
JOIN order_items oi
    ON obt.order_id = oi.order_id
GROUP BY oi.seller_id
HAVING COUNT(DISTINCT obt.order_id) >= 20
ORDER BY avg_delay DESC;


-- ========================================
-- CUSTOMER EXPERIENCE SIGNAL
-- ========================================
SELECT
    CASE
        WHEN obt.delivery_delay_days <= 0 THEN 'On Time / Early'
        WHEN obt.delivery_delay_days BETWEEN 1 AND 3 THEN '1-3 Days Late'
        WHEN obt.delivery_delay_days BETWEEN 4 AND 7 THEN '4-7 Days Late'
        ELSE '8+ Days Late'
    END AS delay_bucket,
    ROUND(AVG(orv.review_score), 2) AS avg_review_score,
    COUNT(*) AS total_reviews
FROM operational_base_table obt
JOIN order_reviews orv
    ON obt.order_id = orv.order_id
GROUP BY delay_bucket
ORDER BY avg_review_score DESC;