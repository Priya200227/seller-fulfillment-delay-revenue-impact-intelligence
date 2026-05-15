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
FROM operational_base_robust
"""

df = pd.read_sql(query, engine)


# ==========================================
# LOAD REGRESSION COEFFICIENTS
# ==========================================

coef_df = pd.read_csv(
    "outputs/regression_coefficients.csv"
)

processing_coef = coef_df.loc[
    coef_df["Feature"] == "seller_processing_days",
    "Coefficient"
].values[0]


# ==========================================
# BASELINE
# ==========================================

baseline_delay = df[
    "delivery_delay_days"
].mean()

print("\nBaseline Average Delay")
print(round(baseline_delay, 2))


# ==========================================
# SIMULATION
# ==========================================

processing_improvement = 2

estimated_delay_change = (
    processing_improvement
    *
    processing_coef
)

new_delay = (
    baseline_delay
    -
    estimated_delay_change
)

print("\nEstimated New Average Delay")
print(round(new_delay, 2))


# ==========================================
# BUSINESS IMPACT
# ==========================================

delay_reduction = (
    baseline_delay
    -
    new_delay
)

print("\nEstimated Delay Reduction")
print(round(delay_reduction, 2))


# ==========================================
# SAVE RESULTS
# ==========================================

os.makedirs("outputs", exist_ok=True)

experiment_results = pd.DataFrame({

    "Metric": [
        "Baseline Delay",
        "Estimated New Delay",
        "Estimated Delay Reduction"
    ],

    "Value": [
        baseline_delay,
        new_delay,
        delay_reduction
    ]
})

experiment_results.to_csv(
    "outputs/operational_experiment_results.csv",
    index=False
)