CREATE TABLE orders_cleaned AS
SELECT
    order_id,
    customer_id,
    order_status,

    CASE
        WHEN CAST(order_purchase_timestamp AS CHAR) = '0000-00-00 00:00:00'
        THEN NULL
        ELSE order_purchase_timestamp
    END AS order_purchase_timestamp,

    CASE
        WHEN CAST(order_approved_at AS CHAR) = '0000-00-00 00:00:00'
        THEN NULL
        ELSE order_approved_at
    END AS order_approved_at,

    CASE
        WHEN CAST(order_delivered_carrier_date AS CHAR) = '0000-00-00 00:00:00'
        THEN NULL
        ELSE order_delivered_carrier_date
    END AS order_delivered_carrier_date,

    CASE
        WHEN CAST(order_delivered_customer_date AS CHAR) = '0000-00-00 00:00:00'
        THEN NULL
        ELSE order_delivered_customer_date
    END AS order_delivered_customer_date,

    CASE
        WHEN CAST(order_estimated_delivery_date AS CHAR) = '0000-00-00 00:00:00'
        THEN NULL
        ELSE order_estimated_delivery_date
    END AS order_estimated_delivery_date

FROM orders;

SELECT COUNT(*) FROM orders_cleaned;


CREATE TABLE orders_operational_clean AS
SELECT *
FROM orders_cleaned
WHERE NOT (
    order_delivered_customer_date < order_purchase_timestamp
    OR order_delivered_carrier_date < order_approved_at
);

SELECT COUNT(*) FROM orders_operational_clean;