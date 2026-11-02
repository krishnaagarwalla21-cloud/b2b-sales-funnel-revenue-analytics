
-- =====================================================
-- B2B SALES FUNNEL & REVENUE ANALYTICS
-- SQL Analysis | SQLite
-- Dataset: 1,000 synthetic B2B leads
-- =====================================================


-- 1. TOTAL NUMBER OF LEADS
SELECT COUNT(*) AS total_leads
FROM b2b_sales_funnel;


-- 2. DATA QUALITY: MISSING VALUES
SELECT
    SUM(CASE WHEN Lead_ID IS NULL THEN 1 ELSE 0 END) AS missing_lead_id,
    SUM(CASE WHEN Company_Name IS NULL THEN 1 ELSE 0 END) AS missing_company,
    SUM(CASE WHEN Industry IS NULL THEN 1 ELSE 0 END) AS missing_industry,
    SUM(CASE WHEN Lead_Source IS NULL THEN 1 ELSE 0 END) AS missing_source,
    SUM(CASE WHEN Lead_Status IS NULL THEN 1 ELSE 0 END) AS missing_status
FROM b2b_sales_funnel;


-- 3. CHECK DUPLICATE LEAD IDs
SELECT Lead_ID, COUNT(*) AS duplicate_count
FROM b2b_sales_funnel
GROUP BY Lead_ID
HAVING COUNT(*) > 1;


-- 4. LEAD DISTRIBUTION BY CURRENT STATUS
SELECT
    Lead_Status,
    COUNT(*) AS lead_count
FROM b2b_sales_funnel
GROUP BY Lead_Status
ORDER BY lead_count DESC;


-- 5. WIN AND LOSS PERFORMANCE
SELECT
    COUNT(*) AS total_leads,
    SUM(CASE WHEN Lead_Status = 'Order Won' THEN 1 ELSE 0 END) AS won_leads,
    ROUND(
        100.0 * SUM(CASE WHEN Lead_Status = 'Order Won' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS win_rate_percentage,
    SUM(CASE WHEN Lead_Status = 'Lost' THEN 1 ELSE 0 END) AS lost_leads,
    ROUND(
        100.0 * SUM(CASE WHEN Lead_Status = 'Lost' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS loss_rate_percentage
FROM b2b_sales_funnel;


-- 6. OVERALL REVENUE PERFORMANCE
SELECT
    COUNT(*) AS total_leads,
    SUM(Deal_Value) AS total_pipeline_value,
    SUM(Actual_Revenue) AS total_actual_revenue,
    ROUND(AVG(Deal_Value), 2) AS average_deal_value
FROM b2b_sales_funnel;


-- 7. LOST LEADS BY REASON
SELECT
    Lost_Reason,
    COUNT(*) AS lost_lead_count,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*)
         FROM b2b_sales_funnel
         WHERE Lead_Status = 'Lost'), 2
    ) AS percentage
FROM b2b_sales_funnel
WHERE Lead_Status = 'Lost'
GROUP BY Lost_Reason
ORDER BY lost_lead_count DESC;


-- 8. LEAD SOURCE PERFORMANCE
SELECT
    Lead_Source,
    COUNT(*) AS total_leads,
    SUM(CASE WHEN Lead_Status = 'Order Won' THEN 1 ELSE 0 END) AS won_leads,
    ROUND(
        100.0 * SUM(CASE WHEN Lead_Status = 'Order Won' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS win_rate_percentage,
    SUM(Actual_Revenue) AS total_revenue
FROM b2b_sales_funnel
GROUP BY Lead_Source
ORDER BY total_revenue DESC;


-- 9. PRODUCT PERFORMANCE
SELECT
    Product,
    COUNT(*) AS total_leads,
    SUM(CASE WHEN Lead_Status = 'Order Won' THEN 1 ELSE 0 END) AS won_leads,
    ROUND(
        100.0 * SUM(CASE WHEN Lead_Status = 'Order Won' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS win_rate_percentage,
    SUM(Actual_Revenue) AS total_revenue
FROM b2b_sales_funnel
GROUP BY Product
ORDER BY total_revenue DESC;


-- 10. INDUSTRY PERFORMANCE
SELECT
    Industry,
    COUNT(*) AS total_leads,
    SUM(CASE WHEN Lead_Status = 'Order Won' THEN 1 ELSE 0 END) AS won_leads,
    ROUND(
        100.0 * SUM(CASE WHEN Lead_Status = 'Order Won' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS win_rate_percentage,
    SUM(Actual_Revenue) AS total_revenue
FROM b2b_sales_funnel
GROUP BY Industry
ORDER BY total_revenue DESC;


-- 11. SALES EXECUTIVE PERFORMANCE
SELECT
    Sales_Executive,
    COUNT(*) AS total_leads,
    SUM(CASE WHEN Lead_Status = 'Order Won' THEN 1 ELSE 0 END) AS won_leads,
    ROUND(
        100.0 * SUM(CASE WHEN Lead_Status = 'Order Won' THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS win_rate_percentage,
    SUM(Actual_Revenue) AS total_revenue
FROM b2b_sales_funnel
GROUP BY Sales_Executive
ORDER BY total_revenue DESC;


-- 12. FOLLOW-UP STATUS
SELECT
    Lead_Status,
    COUNT(*) AS total_leads,
    SUM(CASE WHEN Last_Followup_Date IS NOT NULL THEN 1 ELSE 0 END)
        AS leads_with_last_followup,
    SUM(CASE WHEN Next_Followup_Date IS NOT NULL THEN 1 ELSE 0 END)
        AS leads_with_next_followup
FROM b2b_sales_funnel
GROUP BY Lead_Status;


-- 13. OVERDUE ACTIVE LEADS
SELECT
    Lead_ID,
    Company_Name,
    Sales_Executive,
    Lead_Status,
    Next_Followup_Date
FROM b2b_sales_funnel
WHERE Lead_Status NOT IN ('Order Won', 'Lost')
  AND Next_Followup_Date IS NOT NULL
  AND date(Next_Followup_Date) < date('now')
ORDER BY date(Next_Followup_Date);


-- 14. WON DEAL VALUE VS ACTUAL REVENUE
SELECT
    COUNT(*) AS won_deals,
    SUM(Deal_Value) AS total_deal_value,
    SUM(Actual_Revenue) AS total_actual_revenue,
    SUM(Actual_Revenue - Deal_Value) AS total_variance,
    ROUND(
        100.0 * SUM(Actual_Revenue - Deal_Value)
        / SUM(Deal_Value), 2
    ) AS variance_percentage
FROM b2b_sales_funnel
WHERE Lead_Status = 'Order Won';


-- 15. FINANCIAL DATA VALIDATION
SELECT
    SUM(CASE WHEN Deal_Value < 0 THEN 1 ELSE 0 END) AS negative_deal_values,
    SUM(CASE WHEN Actual_Revenue < 0 THEN 1 ELSE 0 END) AS negative_revenue,
    SUM(CASE WHEN Lead_Status != 'Order Won'
              AND Actual_Revenue > 0 THEN 1 ELSE 0 END) AS revenue_on_unwon_leads,
    SUM(CASE WHEN Lead_Status = 'Order Won'
              AND Actual_Revenue <= 0 THEN 1 ELSE 0 END) AS won_without_revenue
FROM b2b_sales_funnel;
