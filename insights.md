# Amazon India E-Commerce Operations: Business Insights Report

This report outlines the financial, operational, and geographical performance metrics derived from the analytical SQL queries executed against our structured data.

## ⚠️ Data Scope & Disclaimer
* **Scope:** The insights and metrics presented in this report are calculated based on a localized, limited sample of transaction logs rather than long-term historical performance datasets.
---

## 📈 Executive Summary (Macro KPIs)

The platform processed a high volume of transactions with solid baseline average order metrics, though it faces a notable operational cancellation/return rate.

* **Total Orders Processed:** 120,229
* **Gross Merchandise Value (GMV):** ₹7,81,79,803.88
* **Net Realized Revenue:** ₹7,12,94,740.00
* **Successful Average Order Value (AOV):** ₹691.76
* **Order Defect Rate (ODR):** 14.28% *(Percentage of total orders lost to cancellations or returns)*

---

## 👥 Customer Segment Performance Matrix

Comparing individual consumer behavior (B2C) against bulk business buyers (B2B) reveals distinct purchasing patterns:

| Performance Metric | Retail B2C Segment | Wholesale B2B Segment |
| :--- | :--- | :--- |
| **Total Orders** | 1,19,435 | 794 |
| **Total Units Sold** | 1,15,117 | 836 |
| **Total Gross Revenue** | ₹7,75,90,831.09 | ₹5,88,972.79 |
| **Average Price Per Unit** | ₹674.02 | ₹704.51 |
| **Average Order Value (AOV)** | ₹649.65 | ₹741.78 |

### Key Segment Takeaways:
* **Volume vs. Value:** The vast majority of market revenue is driven heavily by the individual retail consumer space (B2C). 
* **B2B Growth Potential:** While small in total volume (794 orders), wholesale business orders yield both a **higher average price per unit** and a **higher average checkout value**. This indicates a highly profitable segment if marketing efforts are scaled to acquire more enterprise buyers.

---

## 📍 Key Regional Market Analysis

Our geographic profiling highlights our primary revenue hubs alongside potential logistics optimization targets.

### 1. Maharashtra (Primary Market Leader)
* **Total Orders:** 20,756
* **Total Gross Revenue:** ₹1,32,61,933.90
* **Cancellation Rate:** 13.36%
* *Observation:* Maharashtra stands as our absolute highest revenue-generating state. However, it displays a little higher operational cancellation rate than Karnataka, meaning logistics pipelines or regional delivery delays should be audited to minimize return-to-origin costs.

### 2. Karnataka (High-Efficiency Growth Market)
* **Total Orders Ranking:** #2 order volume and revenue.
* **Cancellation Rate:** 12.96%
* *Observation:* Karnataka represents an incredibly healthy market. It balances high order volumes with the **lowest cancellation rate** among our top regions, showcasing superior operational delivery stability.


---

## 📅 Advanced Trend & Product Performance

### 1. Month-over-Month (MoM) Growth Trends
* **The Q2 Launch Spike:** Sales experienced a massive structural surge in **April 2022**, rocketing to **₹2,60,38,781.00** in net revenue compared to the initial baseline tracking in March. 
* **Stabilization Phase:** Following the April peak, sales entered a normalization period in **May (₹2.38 Crore, -8.42%)** and **June (₹2.13 Crore, -10.61%)**.

### 2. Core Product Category Dominance
* **The Hero Category:** **T-Shirts** are the primary business driver for the storefront, generating **₹3,90,74,570.36** in gross revenue.
* **Revenue Share:** T-shirts alone command **49.98%** (nearly half) of the platform's total cumulative financial volume. This reveals a massive structural reliance on a single product type for revenue stability.

An audit of fulfillment channels (Amazon vs. Merchant Self-Ship) and delivery statuses reveals where operational bottlenecks occur:

* **High Shipment Stability:** Both Amazon (74k+ orders) and Merchant (30k+ orders) maintain a **0.00% operational loss rate** once a package is officially logged as *Shipped*.
* **The "Unshipped" Amazon Risk:** Orders handled via Amazon that remain in an *Unshipped* status carry a **91.45% cancellation/failure rate**, indicating that warehouse processing delays directly trigger lost orders. 
* **Merchant Pipeline Lag:** A specific cluster of 6,600 Merchant-fulfilled orders marked *On the Way* accounts for a **99.95% failure rate**, highlighting a data logging lag where cancelled self-shipped orders fail to update their courier tracking status correctly.

Tableau Dashboard - https://public.tableau.com/shared/4MK6GSGD2?:display_count=n&:origin=viz_share_link