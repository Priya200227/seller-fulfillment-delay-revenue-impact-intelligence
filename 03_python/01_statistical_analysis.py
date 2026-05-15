import os
import pandas as pd

import matplotlib.pyplot as plt
import seaborn as sns

from scipy.stats import mannwhitneyu

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
# MANN-WHITNEY U TEST
# Reason: Review scores are ordinal (1-5 scale) and delivery delay
# data is right-skewed. Both violate normality assumptions required
# for T-test. Mann-Whitney U is the correct non-parametric alternative.
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

# Mann-Whitney U Test
u_stat, p_value = mannwhitneyu(
    on_time_reviews,
    late_reviews,
    alternative='two-sided'
)

print("\nMann-Whitney U Test Results")
print(f"H0: Delivery delays do not significantly affect customer review scores")
print(f"H1: Delayed deliveries produce significantly lower review scores")
print(f"\nU-Statistic: {u_stat:.4f}")
print(f"P-Value: {p_value:.10f}")

print("\nMedian Review Scores")
print(f"On-Time/Early Deliveries: {on_time_reviews.median():.2f}")
print(f"Late Deliveries: {late_reviews.median():.2f}")

print("\nMean Review Scores (for reference)")
print(f"On-Time/Early: {on_time_reviews.mean():.2f}")
print(f"Late Delivery: {late_reviews.mean():.2f}")

if p_value < 0.05:
    print("\nResult: REJECT H0 — Statistically significant difference detected (α = 0.05)")
    print("Business Decision: Delivery delays have a measurable negative impact on customer satisfaction.")
    print("Recommendation: Seller SLA enforcement is statistically justified.")
else:
    print("\nResult: FAIL TO REJECT H0 — No statistically significant difference at α = 0.05")


# ==========================================
# SAVE MANN-WHITNEY U TEST RESULTS
# ==========================================

mannwhitney_results = pd.DataFrame({

    "Metric": [
        "U-Statistic",
        "P-Value",
        "On-Time Review Median",
        "Late Review Median",
        "On-Time Review Mean",
        "Late Review Mean",
        "Test Used",
        "Reason"
    ],

    "Value": [
        round(u_stat, 4),
        round(p_value, 10),
        on_time_reviews.median(),
        late_reviews.median(),
        round(on_time_reviews.mean(), 2),
        round(late_reviews.mean(), 2),
        "Mann-Whitney U Test",
        "Non-normal distribution — ordinal review scores and right-skewed delay data"
    ]
})

mannwhitney_results.to_csv(
    "outputs/mannwhitney_results.csv",
    index=False
)

print("\nMann-Whitney U Test results saved to outputs/mannwhitney_results.csv")
