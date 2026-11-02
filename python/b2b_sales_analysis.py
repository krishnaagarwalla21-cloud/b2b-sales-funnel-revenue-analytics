
# ============================================================
# B2B SALES FUNNEL & REVENUE ANALYTICS
# Python Analysis
# Dataset: 1,000 synthetic B2B leads
# ============================================================

import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

# 1. SET PROJECT PATHS

PROJECT_DIR = Path(__file__).resolve().parent.parent
DATA_PATH = PROJECT_DIR / "data" / "b2b_sales_funnel.csv"
IMAGE_DIR = PROJECT_DIR / "images"

IMAGE_DIR.mkdir(parents=True, exist_ok=True)

# 2. LOAD DATASET

df = pd.read_csv(DATA_PATH)

print("\n========== DATASET OVERVIEW ==========")
print("Total records:", len(df))
print("Total columns:", len(df.columns))
print("\nColumn names:")
print(df.columns.tolist())

print("\nFirst five records:")
print(df.head())

# 3. DATA QUALITY CHECKS

print("\n========== DATA QUALITY ==========")

print("\nMissing values:")
print(df.isnull().sum())

print("\nDuplicate Lead IDs:", df["Lead_ID"].duplicated().sum())

# 4. CONVERT DATE COLUMN

df["Lead_Date"] = pd.to_datetime(df["Lead_Date"], errors="coerce")

# 5. SALES FUNNEL ANALYSIS

print("\n========== SALES FUNNEL ==========")

status_counts = df["Lead_Status"].value_counts()
print(status_counts)

plt.figure(figsize=(10, 6))
status_counts.plot(kind="bar")
plt.title("Distribution of Leads by Current Status")
plt.xlabel("Lead Status")
plt.ylabel("Number of Leads")
plt.xticks(rotation=35, ha="right")
plt.tight_layout()
plt.savefig(IMAGE_DIR / "lead_status_distribution.png", dpi=300)
plt.close()

# 6. WIN AND LOSS ANALYSIS

total_leads = len(df)
won_leads = (df["Lead_Status"] == "Order Won").sum()
lost_leads = (df["Lead_Status"] == "Lost").sum()

win_rate = won_leads / total_leads * 100
loss_rate = lost_leads / total_leads * 100

print("\n========== WIN / LOSS ANALYSIS ==========")
print("Total leads:", total_leads)
print("Won leads:", won_leads)
print("Lost leads:", lost_leads)
print(f"Win rate: {win_rate:.2f}%")
print(f"Loss rate: {loss_rate:.2f}%")

# 7. REVENUE BY LEAD SOURCE

source_revenue = (
    df.groupby("Lead_Source")["Actual_Revenue"]
    .sum()
    .sort_values(ascending=False)
)

print("\n========== REVENUE BY SOURCE ==========")
print(source_revenue)

plt.figure(figsize=(10, 6))
source_revenue.plot(kind="bar")
plt.title("Actual Revenue by Lead Source")
plt.xlabel("Lead Source")
plt.ylabel("Actual Revenue")
plt.xticks(rotation=35, ha="right")
plt.tight_layout()
plt.savefig(IMAGE_DIR / "revenue_by_source.png", dpi=300)
plt.close()

# 8. WIN RATE BY LEAD SOURCE

source_performance = df.groupby("Lead_Source").agg(
    Total_Leads=("Lead_ID", "count"),
    Won_Leads=("Lead_Status", lambda x: (x == "Order Won").sum())
)

source_performance["Win_Rate"] = (
    source_performance["Won_Leads"]
    / source_performance["Total_Leads"] * 100
)

print("\n========== SOURCE WIN RATE ==========")
print(source_performance.sort_values("Win_Rate", ascending=False))

plt.figure(figsize=(10, 6))
source_performance["Win_Rate"].sort_values(ascending=False).plot(kind="bar")
plt.title("Win Rate by Lead Source")
plt.xlabel("Lead Source")
plt.ylabel("Win Rate (%)")
plt.xticks(rotation=35, ha="right")
plt.tight_layout()
plt.savefig(IMAGE_DIR / "win_rate_by_source.png", dpi=300)
plt.close()

# 9. PRODUCT PERFORMANCE

product_revenue = (
    df.groupby("Product")["Actual_Revenue"]
    .sum()
    .sort_values(ascending=False)
)

print("\n========== PRODUCT PERFORMANCE ==========")
print(product_revenue)

plt.figure(figsize=(9, 6))
product_revenue.plot(kind="bar")
plt.title("Actual Revenue by Product")
plt.xlabel("Product")
plt.ylabel("Actual Revenue")
plt.xticks(rotation=20, ha="right")
plt.tight_layout()
plt.savefig(IMAGE_DIR / "revenue_by_product.png", dpi=300)
plt.close()

# 10. LOST LEADS ANALYSIS

lost_df = df[df["Lead_Status"] == "Lost"]

lost_reasons = lost_df["Lost_Reason"].value_counts()

print("\n========== LOST LEAD REASONS ==========")
print(lost_reasons)

plt.figure(figsize=(9, 6))
lost_reasons.plot(kind="bar")
plt.title("Reasons for Lost Leads")
plt.xlabel("Lost Reason")
plt.ylabel("Number of Leads")
plt.xticks(rotation=35, ha="right")
plt.tight_layout()
plt.savefig(IMAGE_DIR / "lost_reasons.png", dpi=300)
plt.close()

# 11. INDUSTRY REVENUE ANALYSIS

industry_revenue = (
    df.groupby("Industry")["Actual_Revenue"]
    .sum()
    .sort_values(ascending=False)
)

print("\n========== REVENUE BY INDUSTRY ==========")
print(industry_revenue)

plt.figure(figsize=(10, 6))
industry_revenue.plot(kind="bar")
plt.title("Actual Revenue by Industry")
plt.xlabel("Industry")
plt.ylabel("Actual Revenue")
plt.xticks(rotation=35, ha="right")
plt.tight_layout()
plt.savefig(IMAGE_DIR / "revenue_by_industry.png", dpi=300)
plt.close()

# 12. MONTHLY LEAD TREND

monthly_leads = (
    df.dropna(subset=["Lead_Date"])
    .set_index("Lead_Date")
    .resample("ME")
    .size()
)

print("\n========== MONTHLY LEAD TREND ==========")
print(monthly_leads.tail(12))

plt.figure(figsize=(12, 6))
monthly_leads.plot(kind="line", marker="o")
plt.title("Monthly Lead Generation Trend")
plt.xlabel("Month")
plt.ylabel("Number of Leads")
plt.tight_layout()
plt.savefig(IMAGE_DIR / "monthly_lead_trend.png", dpi=300)
plt.close()

# 13. OVERALL REVENUE SUMMARY

total_pipeline = df["Deal_Value"].sum()
total_revenue = df["Actual_Revenue"].sum()

print("\n========== REVENUE SUMMARY ==========")
print(f"Total pipeline value: {total_pipeline:,.2f}")
print(f"Total actual revenue: {total_revenue:,.2f}")
print(f"Average deal value: {df['Deal_Value'].mean():,.2f}")

# 14. SAVE ANALYSIS SUMMARY

summary = pd.DataFrame({
    "Metric": [
        "Total Leads",
        "Won Leads",
        "Lost Leads",
        "Win Rate (%)",
        "Loss Rate (%)",
        "Total Pipeline Value",
        "Total Actual Revenue"
    ],
    "Value": [
        total_leads,
        won_leads,
        lost_leads,
        round(win_rate, 2),
        round(loss_rate, 2),
        total_pipeline,
        total_revenue
    ]
})

summary.to_csv(IMAGE_DIR / "analysis_summary.csv", index=False)

print("\nAnalysis completed successfully!")
print("Charts and summary saved in the images folder.")
