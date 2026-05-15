import os
import pandas as pd

import matplotlib.pyplot as plt
import seaborn as sns

from scipy.stats import ttest_ind

from db_connection import get_engine


# ==========================================
# DATABASE CONNECTION
# ==========================================

engine = get_engine()

print("Connected Successfully")


# ==========================================
# LOAD DATA
# ==========================================

query = """
SELECT *
FROM operational_base_robust
"""

df = pd.read_sql(query, engine)

print("\nDataset Shape")
print(df.shape)


# ==========================================
# CORRELATION ANALYSIS
# ==========================================

correlation_cols = [
    "seller_processing_days",
    "delivery_delay_days",
    "total_order_value",
    "total_products",
    "total_sellers"
]

corr_matrix = df[correlation_cols].corr()

print("\nCorrelation Matrix")
print(corr_matrix)


# ==========================================
# SAVE CORRELATION MATRIX
# ==========================================

os.makedirs("outputs", exist_ok=True)

corr_matrix.to_csv(
    "outputs/correlation_matrix.csv"
)


# ==========================================
# HEATMAP
# ==========================================

plt.figure(figsize=(10, 8))

sns.heatmap(
    corr_matrix,
    annot=True
)

plt.title("Operational Correlation Matrix")

plt.tight_layout()

plt.savefig(
    "outputs/correlation_heatmap.png"
)

plt.show()


# ==========================================
# T-TEST
# ==========================================

review_query = """
SELECT
    obr.delivery_delay_days,
    obr.is_late_delivery,
    orv.review_score

FROM operational_base_robust obr

JOIN order_reviews orv
    ON obr.order_id = orv.order_id
"""

review_df = pd.read_sql(review_query, engine)

on_time_reviews = review_df[
    review_df["is_late_delivery"] == 0
]["review_score"]

late_reviews = review_df[
    review_df["is_late_delivery"] == 1
]["review_score"]

t_stat, p_value = ttest_ind(
    on_time_reviews,
    late_reviews,
    equal_var=False
)

print("\nT-Test Results")
print(f"T-statistic: {t_stat:.4f}")
print(f"P-value: {p_value:.10f}")

print("\nAverage Review Scores")
print(f"On-Time/Early: {on_time_reviews.mean():.2f}")
print(f"Late Delivery: {late_reviews.mean():.2f}")


# ==========================================
# SAVE T-TEST RESULTS
# ==========================================

ttest_results = pd.DataFrame({

    "Metric": [
        "T-statistic",
        "P-value",
        "On-Time Review Mean",
        "Late Review Mean"
    ],

    "Value": [
        t_stat,
        p_value,
        on_time_reviews.mean(),
        late_reviews.mean()
    ]
})

ttest_results.to_csv(
    "outputs/ttest_results.csv",
    index=False
)