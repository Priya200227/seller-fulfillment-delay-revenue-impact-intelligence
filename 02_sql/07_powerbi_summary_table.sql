DROP TABLE IF EXISTS powerbi_seller_summary;

CREATE TABLE powerbi_seller_summary AS

SELECT
    sop.seller_id,

    sop.total_orders,

    sop.avg_delivery_delay,

    sop.avg_processing_days,

    sop.late_delivery_rate,

    sop.total_revenue,

    sop.avg_review_score,

    srif.risk_index,

    srif.risk_category

FROM seller_operational_performance sop

JOIN seller_risk_index_final srif
    ON sop.seller_id = srif.seller_id;
    
    
-- =============================
-- SELLER SUMMARY TABLE
-- =============================

CREATE TABLE powerbi_seller_summary AS

SELECT
    sop.seller_id,
    sop.total_orders,
    sop.avg_delivery_delay,
    sop.avg_processing_days,
    sop.late_delivery_rate,
    sop.total_revenue,
    sop.avg_review_score,
    sri.risk_index,
    sri.risk_category
FROM seller_operational_performance sop
JOIN (
    SELECT
        seller_id,
        risk_index,
        risk_category
    FROM seller_risk_segmentation_v2
) sri
ON sop.seller_id = sri.seller_id;


-- ================================
-- SQL RISK INDEX TABLE
-- ================================

CREATE TABLE seller_risk_index_sql AS
SELECT
    seller_id,
    late_delivery_rate,
    avg_processing_days,
    avg_review_score,
    total_revenue,
    ((late_delivery_rate * 0.4) + (avg_processing_days * 0.3)
        +
	((5 - avg_review_score) * 10 * 0.3)) AS raw_risk_index
FROM seller_operational_performance;



-- ==================================
-- NORMALIZE RISK SCORE IN SQL
-- ===================================
CREATE TABLE seller_risk_index_final (
    seller_id VARCHAR(50),
    late_delivery_rate DECIMAL(10,2),
    avg_processing_days DECIMAL(10,2),
    avg_review_score DECIMAL(10,2),
    total_revenue DECIMAL(15,2),
    raw_risk_index DECIMAL(10,4),
    risk_index DECIMAL(10,4),
    risk_category VARCHAR(20)
);

INSERT INTO seller_risk_index_final

WITH risk_bounds AS (
    SELECT
        MIN(raw_risk_index) AS min_risk,
        MAX(raw_risk_index) AS max_risk
    FROM seller_risk_index_sql
)
SELECT
    sri.*,
    ROUND(((sri.raw_risk_index - rb.min_risk)
        / (rb.max_risk - rb.min_risk)) * 100, 4) AS risk_index,
    CASE
        WHEN ((sri.raw_risk_index - rb.min_risk)
            / (rb.max_risk - rb.min_risk)) * 100 >= 70
        THEN 'High Risk'
        WHEN ((sri.raw_risk_index - rb.min_risk)
            / (rb.max_risk - rb.min_risk)) * 100 >= 40
        THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_category
FROM seller_risk_index_sql sri
CROSS JOIN risk_bounds rb;