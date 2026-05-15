-- ======================================
-- SELLER PERFORMANCE TABLE
-- ======================================

CREATE TABLE seller_operational_performance AS
SELECT
    oi.seller_id,
    COUNT(DISTINCT obr.order_id) AS total_orders,
    ROUND(AVG(obr.delivery_delay_days), 2) AS avg_delivery_delay,
    ROUND(AVG(obr.seller_processing_days), 2) AS avg_processing_days,
    ROUND(SUM(obr.is_late_delivery) * 100.0 / COUNT(*), 2) AS late_delivery_rate,
    ROUND(AVG(obr.total_order_value), 2) AS avg_order_value,
    ROUND(SUM(obr.total_order_value), 2) AS total_revenue,
    ROUND(AVG(orv.review_score), 2) AS avg_review_score
FROM operational_base_robust obr
JOIN order_items oi
    ON obr.order_id = oi.order_id
LEFT JOIN order_reviews orv
    ON obr.order_id = orv.order_id
GROUP BY oi.seller_id
HAVING COUNT(DISTINCT obr.order_id) >= 20;


-- ===============================
-- RISK SEGMENTS
-- ===============================

CREATE TABLE seller_risk_segmentation AS
SELECT *,
    CASE
        WHEN late_delivery_rate >= 40
             OR avg_processing_days >= 10
             OR avg_review_score <= 2.5
        THEN 'High Risk'
        WHEN late_delivery_rate BETWEEN 20 AND 39.99
             OR avg_processing_days BETWEEN 5 AND 9.99
        THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS seller_risk_category
FROM seller_operational_performance;


-- ======================================
-- RISK SEGMENT ANALYSIS
-- ======================================

SELECT
    seller_risk_category,
    COUNT(*) AS total_sellers,
    ROUND(AVG(avg_delivery_delay), 2) AS avg_delay,
    ROUND(AVG(late_delivery_rate), 2) AS avg_late_rate,
    ROUND(AVG(avg_review_score), 2) AS avg_review,
    ROUND(SUM(total_revenue), 2) AS total_revenue
FROM seller_risk_segmentation
GROUP BY seller_risk_category
ORDER BY avg_late_rate DESC;



-- ======================================
-- REVENUE EXPOSURE ANALYSIS
-- ======================================

SELECT
    seller_risk_category,
    ROUND( SUM(total_revenue) * 100.0 / 
			SUM(SUM(total_revenue)) OVER(), 2) AS revenue_share_percentage
FROM seller_risk_segmentation
GROUP BY seller_risk_category;



-- ======================================
-- IDENTIFY PRIORITY SELLERS
-- ======================================

SELECT
    seller_id,
    total_orders,
    avg_delivery_delay,
    avg_processing_days,
    late_delivery_rate,
    total_revenue,
    avg_review_score
FROM seller_risk_segmentation
WHERE seller_risk_category = 'High Risk'
ORDER BY total_revenue DESC
LIMIT 20;


-- ===================================
-- REFINED SEGMENTATION
-- ===================================

CREATE TABLE seller_risk_segmentation_v2 AS
SELECT *,
    CASE
        WHEN late_delivery_rate >= 30
             OR avg_processing_days >= 12
             OR avg_review_score <= 3
        THEN 'High Risk'
        WHEN late_delivery_rate BETWEEN 15 AND 29.99
             OR avg_processing_days BETWEEN 7 AND 11.99
        THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS seller_risk_category
FROM seller_operational_performance;



-- =====================================
-- REFINED SEGMENTATION
-- =====================================

SELECT
    seller_risk_category,
    COUNT(*) AS total_sellers,
    ROUND(AVG(avg_delivery_delay), 2) AS avg_delay,
    ROUND(AVG(late_delivery_rate), 2) AS avg_late_rate,
    ROUND(AVG(avg_review_score), 2) AS avg_review,
    ROUND(SUM(total_revenue), 2) AS total_revenue
FROM seller_risk_segmentation_v2
GROUP BY seller_risk_category;