import os
import pandas as pd

from sklearn.linear_model import LinearRegression

from sklearn.model_selection import train_test_split

from sklearn.metrics import (
    r2_score,
    mean_absolute_error
)

from sklearn.preprocessing import StandardScaler

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
# FEATURES
# ==========================================

features = [
    "seller_processing_days",
    "total_order_value",
    "total_products",
    "total_sellers"
]

X = df[features]

y = df["delivery_delay_days"]


# ==========================================
# FEATURE SCALING
# ==========================================

scaler = StandardScaler()

X = scaler.fit_transform(X)


# ==========================================
# TRAIN TEST SPLIT
# ==========================================

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42
)


# ==========================================
# MODEL TRAINING
# ==========================================

model = LinearRegression()

model.fit(X_train, y_train)

y_pred = model.predict(X_test)


# ==========================================
# MODEL EVALUATION
# ==========================================

r2 = r2_score(y_test, y_pred)

mae = mean_absolute_error(y_test, y_pred)

print("\nRegression Results")
print(f"R² Score: {r2:.4f}")
print(f"MAE: {mae:.2f}")


# ==========================================
# FEATURE COEFFICIENTS
# ==========================================

coefficients = pd.DataFrame({
    "Feature": features,
    "Coefficient": model.coef_
})

print("\nFeature Coefficients")
print(coefficients)


# ==========================================
# SAVE OUTPUTS
# ==========================================

os.makedirs("outputs", exist_ok=True)

coefficients.to_csv(
    "outputs/regression_coefficients.csv",
    index=False
)

model_metrics = pd.DataFrame({

    "Metric": [
        "R2 Score",
        "MAE"
    ],

    "Value": [
        r2,
        mae
    ]
})

model_metrics.to_csv(
    "outputs/regression_metrics.csv",
    index=False
)