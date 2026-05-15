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


# ==========================================
# ALERT RULES
# ==========================================

alerts = seller_df[

    (
        seller_df["late_delivery_rate"] >= 25
    )

    |

    (
        seller_df["avg_processing_days"] >= 10
    )

    |

    (
        seller_df["avg_review_score"] <= 3
    )

]


# ==========================================
# SORT ALERTS
# ==========================================

alerts = alerts.sort_values(
    by="late_delivery_rate",
    ascending=False
)


# ==========================================
# OUTPUT
# ==========================================

print("\nOperational Alerts")
print(alerts.head(20))


# ==========================================
# SAVE ALERTS
# ==========================================

os.makedirs("outputs", exist_ok=True)

alerts.to_csv(
    "outputs/seller_operational_alerts.csv",
    index=False
)

print("\nAlert report exported successfully")