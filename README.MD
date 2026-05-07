
# 🛒 E-Commerce Return Fraud & Revenue Leakage Analysis

> **"1 in 5 orders is being returned. R$1,543,899 lost to refunds. 18,944 suspicious customers. Nobody was tracking it — until now."**

---

## 🎯 Business Problem

E-commerce platforms lose millions every year to return fraud and refund abuse.  
This project identifies **who** is abusing returns, **which products** are most affected,  
**which sellers** are problematic, and **how much revenue** can be recovered with data-driven action.

---

## 📊 Key Findings at a Glance

| Metric | Value |
|--------|-------|
| 📦 Total Orders Analyzed | 1,12,650 |
| 💰 Total Revenue | R$15,843,553 |
| 🔴 Total Refund Loss | R$1,543,899 |
| 📉 Revenue Loss % | 9.74% |
| ⚠️ Return Rate | 20.60% (Industry avg: 8-10%) |
| 🚨 High Risk Customers | 18,944 |
| 🏪 Worst Seller Return Rate | 39.22% |
| 📅 Worst Month | November 2017 (Festival Season) |

---

## 🗂️ Project Structure

```
ecommerce-fraud-analysis/
│
├── 📁 data/
│   ├── master_ecommerce.csv       # 1,12,650 rows master dataset
│   ├── customer_profile.csv       # 95,420 unique customers
│   ├── order_details.csv          # Order level analysis
│   ├── product_analysis.csv       # 72 product categories
│   ├── fraud_analysis.csv         # Customer fraud flags
│   └── revenue_leakage.csv        # 24 months trend
│
├── 📁 notebooks/
│   └── ecommerce_return_fraud_analysis.ipynb   # Data cleaning & merging
│
├── 📁 sql/
│   └── business_queries.sql       # 16 business queries + insights
│
├── 📁 dashboard/
│   └── (Power BI Dashboard — Coming Soon)
│
└── README.md
```

---

## 🔍 SQL Analysis — 16 Business Queries
### Q1 — Overall Business Health Check

**Why:** To evaluate baseline business performance and total refund impact
**Finding:** R$9.74 out of every R$100 in revenue is lost through refunds
**Impact:** 9.74% revenue leakage indicates an immediate need for operational intervention

---

### Q2 — Category-wise Return Risk Ranking

**Why:** To identify categories with the highest return concentration
**Window Function:** `RANK()`
**Finding:** Fashion Female Clothing recorded a 31.25% return rate — highest across all categories
**Impact:** Fashion categories are major contributors to refund-related losses

---

### Q3 — High-Risk Customer Quartile Analysis

**Why:** To segment customers based on return behavior patterns
**Window Function:** `NTILE(4)`
**Finding:** Top customer quartile showed return rates approaching 100%, with credit cards being the most used payment method
**Impact:** The top 20 customers accounted for more than R$6,500 in refunds

---

### Q4 — Price Range Refund Performance

**Why:** To determine which order-value segments contribute most to refund losses
**Finding:** Orders below R$50 generated the highest refund volume — R$535,263 in losses
**Impact:** Low-value product segments may require stricter return-control measures

---

### Q5 — Category & Price Range Pivot Analysis

**Why:** To identify return concentration across category-price combinations
**Finding:** Bed Bath Table (R$0–50) recorded 704 returns, while Telephony recorded 708 returns in the same range
**Impact:** Low-cost telephony products emerged as a significant return-risk segment

---

### Q6 — Return Rate by Price Band

**Why:** To evaluate return percentages across different category-price combinations
**Finding:** Industry Commerce products in the R$0–50 range recorded a 57.89% return rate — highest observed
**Impact:** Certain price bands require targeted return-management strategies

---

### Q7 — High Return Rate Category Deep Dive

**Why:** To investigate categories with consistently high return rates
**Finding:** Fashion Shoes priced above R$200 recorded a 36.36% return rate
**Impact:** Premium fashion products may require stricter return validation policies

---

### Q8 — Category Return & Refund Loss Breakdown

**Why:** To compare refund performance across price segments
**Finding:** Products above R$200 showed return rates comparable to or higher than lower-priced items
**Impact:** Return-risk is not limited to low-cost products alone

---

### Q9 — Complete Category Performance Summary

**Why:** To evaluate platform-wide category performance
**Finding:** 54 categories demonstrated consistently elevated return rates
**Impact:** The issue appears systemic rather than isolated to a few product categories

---

### Q10 — Same-Day & Two-Day Return Analysis

**Why:** To identify unusually rapid return behavior patterns
**Finding:** Food products recorded a 3.37% quick-return rate, while Perfumery recorded 1.39%
**Impact:** Perishable categories may require stricter return policies

---

### Q11 — Customer Return-Risk Signals

**Why:** To identify suspicious customer return behavior patterns
**Finding:** Customers with 50–75% return rates most frequently selected “Changed Mind” as the return reason
**Impact:** A small group of customers contributed disproportionately to refund losses

---

### Q12 — Fashion Wardrobing Detection

**Why:** To detect potential wardrobing behavior in fashion categories
**Finding:** “Changed Mind” returns occurred after an average of 227 days in fashion-related orders
**Impact:** Fashion-related returns contributed more than R$40,000 in refund losses

---

### Q13 — Return Reason Performance by Category

**Why:** To analyze return reasons across different categories
**Window Function:** `SUM() OVER (PARTITION BY)`
**Finding:** Return patterns were driven primarily by three factors — customer behavior, seller-side issues, and operational errors
**Impact:** Each issue category requires a different corrective strategy

---

### Q14 — Seller Return & Refund Performance

**Why:** To identify sellers contributing most to return-related losses
**Finding:** Seller 048c27 recorded a 39.22% return rate, while Seller 7ea5bf generated R$2,238 in refund losses
**Impact:** The top 5 sellers were responsible for over R$8,000 in avoidable refund losses

---

### Q15 — Platform-wide Return Performance Summary

**Why:** To compare overall platform return performance against industry standards
**Finding:** The platform recorded a 20.60% return rate — nearly double the industry benchmark
**Impact:** Elevated returns indicate a broader operational and customer-experience issue

---

### Q16 — Monthly Revenue Leakage Trend

**Why:** To monitor refund-related revenue leakage over time
**Window Function:** `LAG()` — Month-over-Month Comparison
**Finding:** November 2017 recorded R$113,402 in refunds — a 40% increase during the festival-sales period
**Impact:** Peak-sales seasons contribute significantly to revenue leakage and require enhanced monitoring

---




## 💡 SQL Techniques Used

| Technique | Used In |
|-----------|---------|
| `RANK()` Window Function | Q2 — Category Fraud Ranking |
| `NTILE(4)` Window Function | Q3 — Customer Quartile Analysis |
| `LAG()` Window Function | Q16 — Month over Month Trend |
| `SUM() OVER (PARTITION BY)` | Q13 — Return Reason % |
| `CASE WHEN` Pivot Tables | Q5, Q6, Q7, Q8 |
| `HAVING` Clause | Q7, Q9, Q14 |
| `MODE()` Aggregate | Q11, Q14 |
| `NULLIF()` Division Safety | Q6, Q8 |
| `ILIKE` Pattern Matching | Q12 |
| Subqueries | Q6, Q8, Q9 |

---

## 🛠️ Tech Stack

| Tool | Purpose |
|------|---------|
| **Python** (Pandas, NumPy) | Data cleaning & merging |
| **PostgreSQL** (Supabase) | Cloud database & SQL analysis |
| **Google Colab** | Analysis environment |
| **Power BI** | Dashboard (Coming Soon) |
| **GitHub** | Version control |

---

## 📈 Data Sources

| Dataset | Rows | Source |
|---------|------|--------|
| Olist Orders | 99,441 | Kaggle — Brazilian E-Commerce |
| Olist Items | 112,650 | Kaggle |
| Olist Customers | 99,441 | Kaggle |
| Olist Reviews | 99,224 | Kaggle |
| Olist Payments | 103,886 | Kaggle |
| Return Data | 10,000 | Kaggle |
| Refund Data | 70,052 | Kaggle |
| Customer Behavior | 2,50,000 | Kaggle |
| **Master Dataset** | **1,12,650** | **Combined & Cleaned** |

---

## 🚀 Business Recommendations

### 🔴 Immediate Actions:
1. **Fashion items** → Photo proof required for all returns
2. **R$200+ items** → Video unboxing required before return accepted
3. **Top 5 sellers** → Immediate suspension or warning issued
4. **Festival season** → Reduce return window from 30 to 7 days

### 🟡 Short Term:
5. **Food category** → No returns policy (perishable items)
6. **Repeat returners** → Flag customers with 50%+ return rate
7. **Seller scorecard** → Monthly return rate tied to commission

### 🟢 Long Term:
8. **ML Model** → Return fraud prediction before order ships
9. **Seller audit** → Quarterly product listing review
10. **Customer segmentation** → Different return policies per segment

### 💰 Estimated Recovery:
| Action | Recovery |
|--------|----------|
| Fashion strict policy | R$40,000+ |
| Seller suspension | R$8,000+ monthly |
| Festival policy | R$45,000 in November |
| Repeat returner flagging | R$25,000+ |
| **Total Potential** | **R$1,18,000+** |

---

## 📅 Project Progress

- [x] Day 1 — Data Collection, Cleaning & PostgreSQL Upload
- [x] Day 2 — 16 SQL Business Queries & Analysis
- [ ] Day 3 — Power BI Dashboard
- [ ] Day 4 — Python EDA & Visualizations

---

## 🔗 Connect

**Gaurav Shukla** — Data Analyst  
- 🔗 LinkedIn: [gaurav-shukla-406934290](https://www.linkedin.com/in/gaurav-shukla-406934290/)
- 📧 Email: gaurav.shuklaml@gmail.com
- ⭐ Open to: Data Analyst | Business Analyst roles | Immediate Joiner

---

*If this project helped you or you found it interesting, please ⭐ star the repository!*
