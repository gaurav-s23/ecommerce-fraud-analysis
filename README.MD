
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
**Why:** Baseline metrics — total loss kitna hai  
**Finding:** Har R$100 mein R$9.74 refund mein ja raha hai  
**Impact:** 9.74% revenue leakage — immediate action needed

### Q2 — Category wise Return & Fraud Ranking
**Why:** Konsi category mein sabse zyada fraud  
**Window Function:** `RANK()`  
**Finding:** Fashion Female Clothing 31.25% — Rank 1 (Wardrobing Fraud!)  
**Impact:** Fashion category top contributor to refund loss

### Q3 — High Risk Customer Quartile Analysis
**Why:** High Risk customers ko groups mein baantna  
**Window Function:** `NTILE(4)`  
**Finding:** Top customers 100% return rate | Credit card most used  
**Impact:** Top 20 customers ne R$6,500+ refund liya

### Q4 — Price Range Refund Performance
**Why:** Konse price band mein sabse zyada refund  
**Finding:** Under R$50 — R$5,35,263 loss (HIGHEST VOLUME)  
**Impact:** Cheap products mein strict policy needed

### Q5 — Category + Price Range Pivot Table
**Why:** Category aur price combination mein fraud pattern  
**Finding:** Bed Bath Table R$0-50 — 704 returns | Telephony — 708 returns  
**Impact:** Telephony cheap items = fraud hotspot

### Q6 — Return Rate % by Price Band
**Why:** Exact fraud % har category ke har price band mein  
**Finding:** Industry Commerce R$0-50 — 57.89% fraud rate (HIGHEST!)  
**Impact:** Specific price bands mein targeted action needed

### Q7 — High Return Rate Categories Deep Dive
**Why:** Sirf high return categories ka deep analysis  
**Finding:** Fashion Shoes R$200+ — 36.36% return rate  
**Impact:** Premium fashion items pe strict return policy = R$8,000+ recovery

### Q8 — Category Return & Refund Loss Breakdown
**Why:** Price range wise exact return % nikalna  
**Finding:** R$200+ products ka return rate cheap products se ZYADA  
**Impact:** Myth busted — fraud premium items mein bhi equally targeted

### Q9 — Complete Category Performance Summary
**Why:** Platform-wide view — saari categories  
**Finding:** 54 categories mein consistent high return rate  
**Impact:** Platform-wide return policy overhaul needed

### Q10 — Same Day & 2 Day Return Fraud
**Why:** Quick returns = suspicious behavior signal  
**Finding:** Food 3.37% quick return | Perfumery 1.39%  
**Impact:** Food category mein no-return policy recommended

### Q11 — Customer Return-Fraud Signals
**Why:** Customer history se suspicious behavior identify karna  
**Finding:** Customers with 50-75% return rate — "Changed Mind" top reason  
**Impact:** Top 20 suspicious customers — R$4,000+ combined refund taken

### Q12 — Fashion Wardrobing Detection
**Why:** Fashion fraud pattern — buy, use, return  
**Finding:** "Changed Mind" after avg 227 days — classic wardrobing!  
**Impact:** Fashion category R$40,000+ total refund loss

### Q13 — Return Reason Performance by Category
**Why:** Har category mein return reason ka % breakdown  
**Window Function:** `SUM() OVER (PARTITION BY)`  
**Finding:** 3 problem types — Fraud | Seller Issue | Operations Error  
**Impact:** Each problem needs different solution — targeted approach

### Q14 — Seller Return & Refund Performance
**Why:** Konsa seller sabse zyada returns cause kar raha hai  
**Finding:** Seller 048c27 — 39.22% return rate | Seller 7ea5bf — R$2,238 loss  
**Impact:** Top 5 sellers responsible for R$8,000+ avoidable refund loss

### Q15 — All Categories Performance Summary
**Why:** Complete platform view  
**Finding:** Platform-wide 20.60% — 2x industry benchmark  
**Impact:** Systemic problem — not isolated incidents

### Q16 — Monthly Revenue Leakage Trend
**Why:** Time series mein revenue loss track karna  
**Window Function:** `LAG()` — month over month change  
**Finding:** Nov 2017 — R$1,13,402 refund (40% spike — festival season!)  
**Impact:** Festival season mein R$45,000 extra loss vs normal months

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
