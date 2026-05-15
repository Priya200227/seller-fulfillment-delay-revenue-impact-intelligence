WITH ranked_delays AS (
	SELECT 
		delivery_delay_days,
        NTILE(100) OVER (ORDER BY delivery_delay_days) AS percentile_rank
	FROM operational_base_table
)
SELECT
	MIN(delivery_delay_days) AS p01,
    MAX(delivery_delay_days) AS p99
FROM ranked_delays
WHERE percentile_rank IN (1,99);



CREATE TABLE operational_base_robust AS
SELECT *
FROM operational_base_table
WHERE delivery_delay_days BETWEEN -30 AND 30
AND seller_processing_days BETWEEN 0 AND 30;