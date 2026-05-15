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
FROM seller_operational_performance
"""

seller_df = pd.read_sql(query, engine)

print("\nDataset Shape")
print(seller_df.shape)


# ==========================================
# RISK INDEX
# ==========================================

seller_df["risk_index"] = (

    seller_df["late_delivery_rate"] * 0.4

    +

    seller_df["avg_processing_days"] * 0.3

    +

    (5 - seller_df["avg_review_score"]) * 10 * 0.3
)


# ==========================================
# NORMALIZE RISK SCORE
# ==========================================

seller_df["risk_index"] = (

    (
        seller_df["risk_index"]
        -
        seller_df["risk_index"].min()
    )

    /

    (
        seller_df["risk_index"].max()
        -
        seller_df["risk_index"].min()
    )

) * 100


# ==========================================
# RISK CATEGORY
# ==========================================

def classify_risk(score):

    if score >= 70:
        return "High Risk"

    elif score >= 40:
        return "Medium Risk"

    else:
        return "Low Risk"


seller_df["risk_category"] = seller_df[
    "risk_index"
].apply(classify_risk)


# ==========================================
# TOP RISK SELLERS
# ==========================================

top_risk_sellers = seller_df.sort_values(
    by="risk_index",
    ascending=False
).head(20)

print("\nTop High-Risk Sellers")

print(top_risk_sellers[
    [
        "seller_id",
        "risk_index",
        "risk_category",
        "late_delivery_rate",
        "avg_processing_days",
        "avg_review_score",
        "total_revenue"
    ]
])


# ==========================================
# SAVE OUTPUTS
# ==========================================

os.makedirs("outputs", exist_ok=True)

top_risk_sellers.to_csv(
    "outputs/top_high_risk_sellers.csv",
    index=False
)

seller_df.to_csv(
    "outputs/full_seller_risk_index.csv",
    index=False
)