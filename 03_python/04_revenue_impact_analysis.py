import os
import pandas as pd

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
FROM seller_risk_segmentation_v2
"""

df = pd.read_sql(query, engine)

print("\nDataset Shape")
print(df.shape)


# ==========================================
# REVENUE ANALYSIS
# ==========================================

revenue_analysis = df.groupby(
    "seller_risk_category"
).agg({

    "total_revenue": "sum",
    "late_delivery_rate": "mean",
    "avg_review_score": "mean"

}).reset_index()


# ==========================================
# REVENUE SHARE
# ==========================================

total_revenue = revenue_analysis[
    "total_revenue"
].sum()

revenue_analysis[
    "revenue_share_percentage"
] = (
    revenue_analysis["total_revenue"]
    /
    total_revenue
) * 100


print("\nRevenue Exposure Analysis")
print(revenue_analysis)


# ==========================================
# SAVE OUTPUTS
# ==========================================

os.makedirs("outputs", exist_ok=True)

revenue_analysis.to_csv(
    "outputs/revenue_exposure_analysis.csv",
    index=False
)