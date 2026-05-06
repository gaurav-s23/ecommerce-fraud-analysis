-- ================================================================
-- E-COMMERCE RETURN FRAUD & REVENUE LEAKAGE ANALYSIS
-- Author  : Gaurav Shukla
-- Tool    : PostgreSQL (Supabase)
-- Dataset : Olist Brazilian E-Commerce + 3 Additional Sources
-- Records : 1,12,650 Orders | 95,420 Customers | 72 Categories
-- GitHub  : github.com/gaurav-s23/ecommerce-fraud-analysis
-- ================================================================

-- ================================================================
-- Q1: OVERALL BUSINESS HEALTH CHECK
-- WHY : Baseline metrics samajhna — total loss kitna hai
-- ================================================================
SELECT 
    COUNT(*) as total_orders,
    ROUND(SUM(total_revenue)::numeric, 2) as total_revenue,
    ROUND(SUM(refund_amount)::numeric, 2) as total_refund_loss,
    ROUND(SUM(net_revenue)::numeric, 2) as net_revenue,
    ROUND(AVG(is_returned::numeric * 100), 2) as return_rate_pct,
    ROUND((SUM(refund_amount) / SUM(total_revenue) * 100)::numeric, 2) as loss_pct
FROM order_details;
/*
RESULT  : 1,12,650 orders | Revenue R$15,843,553 | Refund Loss R$1,543,899 | Return Rate 20.60%
INSIGHT : Har R$100 mein R$9.74 refund mein ja raha hai
IMPACT  : 9.74% revenue leakage — immediate action needed
*/

-- ================================================================
-- Q2: CATEGORY WISE RETURN & FRAUD RANKING
-- WHY : Konsi category mein sabse zyada fraud ho raha hai
-- WINDOW FUNCTION : RANK()
-- ================================================================
SELECT 
    product_category,
    COUNT(*) as total_orders,
    SUM(is_returned) as total_returns,
    ROUND(AVG(is_returned::numeric * 100), 2) as return_rate_pct,
    ROUND(SUM(refund_amount)::numeric, 2) as total_refund_loss,
    ROUND(AVG(rating)::numeric, 2) as avg_rating,
    ROUND(SUM(refund_amount)::numeric / COUNT(*)::numeric, 2) as avg_loss_per_order,
    RANK() OVER (ORDER BY AVG(is_returned) DESC) as fraud_rank
FROM order_details
GROUP BY product_category
ORDER BY return_rate_pct DESC
LIMIT 15;
/*
RESULT  : Fashio Female Clothing 31.25% (Rank 1) | Construction Tools 26.21% | Food Drink 24.46%
INSIGHT : Fashion categories mein "Wardrobing Fraud" — pehno aur wapas karo
IMPACT  : Fashion category R$15,000+ refund loss top contributor
*/

-- ================================================================
-- Q3: HIGH RISK REFUND ANALYSIS — CUSTOMER QUARTILES
-- WHY : High Risk customers ko quartile mein baantna
-- WINDOW FUNCTION : NTILE(4)
-- ================================================================
SELECT 
    fa.customer_unique_id,
    fa.total_orders,
    fa.total_returns,
    ROUND(fa.return_rate_pct::numeric, 2) as return_rate_pct,
    ROUND(fa.total_refund_taken::numeric, 2) as total_refund_taken,
    ROUND(fa.avg_order_value::numeric, 2) as avg_order_value,
    fa.most_used_payment,
    fa.most_returned_category,
    fa.fraud_flag,
    fa.risk_score,
    NTILE(4) OVER (ORDER BY fa.total_refund_taken DESC) as refund_quartile
FROM fraud_analysis fa
WHERE fa.fraud_flag = 'High Risk'
ORDER BY fa.total_refund_taken DESC
LIMIT 20;
/*
RESULT  : Top fraud customers — 100% return rate | Credit card most used | Furniture Decor top category
INSIGHT : High Risk customers credit card use karte hain — easy refund ke liye
IMPACT  : Top 20 customers ne R$6,500+ refund liya
*/

-- ================================================================
-- Q4: PRICE RANGE REFUND PERFORMANCE
-- WHY : Konse price band mein sabse zyada refund ho raha hai
-- ================================================================
SELECT 
    CASE 
        WHEN price < 50   THEN '1. Under R$50'
        WHEN price < 100  THEN '2. R$50-100'
        WHEN price < 200  THEN '3. R$100-200'
        WHEN price < 500  THEN '4. R$200-500'
        ELSE              '5. Above R$500'
    END as price_range,
    COUNT(*) as total_orders,
    SUM(is_returned) as total_returns,
    ROUND(AVG(is_returned::numeric * 100), 2) as return_rate_pct,
    ROUND(SUM(refund_amount)::numeric, 2) as total_refund_loss
FROM order_details
GROUP BY price_range
ORDER BY price_range;
/*
RESULT  : Under R$50 — 39,024 orders, 8,014 returns, R$5,35,263 loss (HIGHEST VOLUME)
INSIGHT : Cheap products sabse zyada return hote hain — volume wise
IMPACT  : R$50 se kam products mein R$5.35L loss — strict policy needed
*/

-- ================================================================
-- Q5: CATEGORY RETURN RATE BY PRICE RANGE (PIVOT TABLE)
-- WHY : Category + Price combination mein fraud pattern dekhna
-- ================================================================
SELECT 
    product_category,
    COUNT(*) as total_orders,
    COUNT(CASE WHEN price < 50 THEN 1 END) as orders_0_50,
    SUM(CASE WHEN price < 50 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_0_50,
    COUNT(CASE WHEN price >= 50 AND price < 100 THEN 1 END) as orders_50_100,
    SUM(CASE WHEN price >= 50 AND price < 100 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_50_100,
    COUNT(CASE WHEN price >= 100 AND price < 200 THEN 1 END) as orders_100_200,
    SUM(CASE WHEN price >= 100 AND price < 200 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_100_200,
    COUNT(CASE WHEN price >= 200 AND price < 500 THEN 1 END) as orders_200_500,
    SUM(CASE WHEN price >= 200 AND price < 500 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_200_500,
    COUNT(CASE WHEN price >= 500 THEN 1 END) as orders_500_plus,
    SUM(CASE WHEN price >= 500 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_500_plus,
    SUM(is_returned) as total_returns,
    ROUND(AVG(is_returned::numeric * 100), 2) as overall_return_rate_pct
FROM order_details
GROUP BY product_category
ORDER BY total_returns DESC
LIMIT 20;
/*
RESULT  : Bed Bath Table — R$0-50 mein 704 returns (highest) | Telephony R$0-50 — 708 returns
INSIGHT : Cheap Telephony items sabse zyada return — fraud hotspot
IMPACT  : Volume wise Bed Bath Table aur Telephony top loss contributors
*/

-- ================================================================
-- Q6: RETURN RATE % BY PRICE BAND — TOP CATEGORIES
-- WHY : Exact fraud % nikalna har category ke har price band mein
-- ================================================================
SELECT 
    product_category,
    total_orders,
    ROUND((returns_0_50::numeric / NULLIF(orders_0_50,0) * 100), 2) as fraud_rate_0_50,
    ROUND((returns_50_100::numeric / NULLIF(orders_50_100,0) * 100), 2) as fraud_rate_50_100,
    ROUND((returns_100_200::numeric / NULLIF(orders_100_200,0) * 100), 2) as fraud_rate_100_200,
    ROUND((returns_200_500::numeric / NULLIF(orders_200_500,0) * 100), 2) as fraud_rate_200_500,
    ROUND((returns_500_plus::numeric / NULLIF(orders_500_plus,0) * 100), 2) as fraud_rate_500_plus,
    overall_return_rate_pct
FROM (
    SELECT 
        product_category,
        COUNT(*) as total_orders,
        COUNT(CASE WHEN price < 50 THEN 1 END) as orders_0_50,
        SUM(CASE WHEN price < 50 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_0_50,
        COUNT(CASE WHEN price >= 50 AND price < 100 THEN 1 END) as orders_50_100,
        SUM(CASE WHEN price >= 50 AND price < 100 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_50_100,
        COUNT(CASE WHEN price >= 100 AND price < 200 THEN 1 END) as orders_100_200,
        SUM(CASE WHEN price >= 100 AND price < 200 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_100_200,
        COUNT(CASE WHEN price >= 200 AND price < 500 THEN 1 END) as orders_200_500,
        SUM(CASE WHEN price >= 200 AND price < 500 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_200_500,
        COUNT(CASE WHEN price >= 500 THEN 1 END) as orders_500_plus,
        SUM(CASE WHEN price >= 500 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_500_plus,
        ROUND(AVG(is_returned::numeric * 100), 2) as overall_return_rate_pct
    FROM order_details
    GROUP BY product_category
) sub
ORDER BY fraud_rate_0_50 DESC
LIMIT 20;
/*
RESULT  : Industry Commerce R$0-50 — 57.89% fraud rate (HIGHEST!) | Fashion Underwear Beach 32.56%
INSIGHT : Industry Commerce cheap items mein 57% return — extremely suspicious
IMPACT  : Specific price bands mein targeted action needed
*/

-- ================================================================
-- Q7: HIGH RETURN RATE CATEGORIES — DETAILED BREAKDOWN
-- WHY : Sirf high return categories ka deep analysis
-- ================================================================
SELECT 
    product_category,
    COUNT(*) as total_orders,
    SUM(is_returned) as total_returns,
    ROUND(AVG(is_returned::numeric * 100), 2) as return_rate_pct,
    ROUND(SUM(refund_amount)::numeric, 2) as total_refund_loss,
    ROUND(AVG(rating)::numeric, 2) as avg_rating,
    COUNT(CASE WHEN price < 50 THEN 1 END) as orders_0_50,
    SUM(CASE WHEN price < 50 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_0_50,
    COUNT(CASE WHEN price >= 50 AND price < 200 THEN 1 END) as orders_50_200,
    SUM(CASE WHEN price >= 50 AND price < 200 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_50_200,
    COUNT(CASE WHEN price >= 200 THEN 1 END) as orders_200_plus,
    SUM(CASE WHEN price >= 200 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_200_plus
FROM order_details
GROUP BY product_category
HAVING AVG(is_returned::numeric * 100) > 22
ORDER BY return_rate_pct DESC;
/*
RESULT  : 14 categories above 22% return rate | Fashion Shoes R$200+ — 36.36%
INSIGHT : Premium fashion items (R$200+) mein highest fraud % — wardrobing confirmed
IMPACT  : R$200+ fashion items pe strict return policy = R$8,000+ recovery
*/

-- ================================================================
-- Q8: CATEGORY RETURN & REFUND LOSS BREAKDOWN
-- WHY : Price range wise exact return % nikalna
-- ================================================================
SELECT 
    product_category,
    total_orders,
    total_returns,
    return_rate_pct,
    total_refund_loss,
    avg_rating,
    ROUND((returns_0_50::numeric / NULLIF(orders_0_50,0) * 100), 2) as return_pct_0_50,
    ROUND((returns_50_200::numeric / NULLIF(orders_50_200,0) * 100), 2) as return_pct_50_200,
    ROUND((returns_200_plus::numeric / NULLIF(orders_200_plus,0) * 100), 2) as return_pct_200_plus
FROM (
    SELECT 
        product_category,
        COUNT(*) as total_orders,
        SUM(is_returned) as total_returns,
        ROUND(AVG(is_returned::numeric * 100), 2) as return_rate_pct,
        ROUND(SUM(refund_amount)::numeric, 2) as total_refund_loss,
        ROUND(AVG(rating)::numeric, 2) as avg_rating,
        COUNT(CASE WHEN price < 50 THEN 1 END) as orders_0_50,
        SUM(CASE WHEN price < 50 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_0_50,
        COUNT(CASE WHEN price >= 50 AND price < 200 THEN 1 END) as orders_50_200,
        SUM(CASE WHEN price >= 50 AND price < 200 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_50_200,
        COUNT(CASE WHEN price >= 200 THEN 1 END) as orders_200_plus,
        SUM(CASE WHEN price >= 200 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_200_plus
    FROM order_details
    GROUP BY product_category
    HAVING COUNT(*) > 100
) sub
ORDER BY return_rate_pct DESC;
/*
RESULT  : Construction Tools R$200+ — 33.33% | Fashion Shoes R$200+ — 36.36% | Furniture R$200+ — 34.29%
INSIGHT : Expensive products (R$200+) ka return rate cheap products se ZYADA hai
IMPACT  : Myth busted — fraud sirf cheap items mein nahi, premium items bhi equally targeted
*/

-- ================================================================
-- Q9: CATEGORY RETURN & REFUND PERFORMANCE SUMMARY
-- WHY : Complete summary view with price breakdown
-- ================================================================
SELECT 
    product_category,
    total_orders,
    total_returns,
    return_rate_pct,
    total_refund_loss,
    avg_rating,
    ROUND((returns_0_50::numeric / NULLIF(orders_0_50,0) * 100), 2) as return_pct_0_50,
    ROUND((returns_50_200::numeric / NULLIF(orders_50_200,0) * 100), 2) as return_pct_50_200,
    ROUND((returns_200_plus::numeric / NULLIF(orders_200_plus,0) * 100), 2) as return_pct_200_plus
FROM (
    SELECT 
        product_category,
        COUNT(*) as total_orders,
        SUM(is_returned) as total_returns,
        ROUND(AVG(is_returned::numeric * 100), 2) as return_rate_pct,
        ROUND(SUM(refund_amount)::numeric, 2) as total_refund_loss,
        ROUND(AVG(rating)::numeric, 2) as avg_rating,
        COUNT(CASE WHEN price < 50 THEN 1 END) as orders_0_50,
        SUM(CASE WHEN price < 50 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_0_50,
        COUNT(CASE WHEN price >= 50 AND price < 200 THEN 1 END) as orders_50_200,
        SUM(CASE WHEN price >= 50 AND price < 200 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_50_200,
        COUNT(CASE WHEN price >= 200 THEN 1 END) as orders_200_plus,
        SUM(CASE WHEN price >= 200 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_200_plus
    FROM order_details
    GROUP BY product_category
    HAVING COUNT(*) > 100
) sub
ORDER BY return_rate_pct DESC;
/*
RESULT  : 54 categories analyzed | Top categories all above 22% return rate
INSIGHT : Consistent high return rate across multiple categories — systemic problem
IMPACT  : Platform-wide return policy overhaul needed, not just category-specific fixes
*/

-- ================================================================
-- Q10: RETURN FRAUD BY PRODUCT CATEGORY — SAME DAY & 2 DAY
-- WHY : Quick returns = suspicious behavior signal
-- ================================================================
SELECT 
    product_category,
    COUNT(*) as total_orders,
    SUM(is_returned) as total_returns,
    COUNT(CASE WHEN days_to_return >= 0 AND days_to_return <= 1 
          AND is_returned = 1 THEN 1 END) as same_day_returns,
    COUNT(CASE WHEN days_to_return > 1 AND days_to_return <= 2 
          AND is_returned = 1 THEN 1 END) as two_day_returns,
    ROUND(AVG(rating)::numeric, 2) as avg_rating,
    ROUND(SUM(refund_amount)::numeric, 2) as total_refund_loss,
    ROUND((COUNT(CASE WHEN days_to_return <= 2 AND is_returned = 1 THEN 1 END)::numeric / 
          NULLIF(SUM(is_returned), 0) * 100), 2) as quick_return_fraud_pct
FROM order_details
GROUP BY product_category
HAVING COUNT(*) > 200
ORDER BY quick_return_fraud_pct DESC
LIMIT 15;
/*
RESULT  : Food 3.37% quick return | Perfumery 1.39% | Housewares 1.21%
INSIGHT : Food aur Perfumery mein quick returns zyada — perishable items fraud pattern
IMPACT  : Food category mein return policy strict karna chahiye — no returns on food items
*/

-- ================================================================
-- Q11: CUSTOMER RETURN-FRAUD SIGNALS
-- WHY : Customer history se suspicious behavior identify karna
-- ================================================================
SELECT 
    customer_unique_id,
    COUNT(DISTINCT order_id) as total_orders,
    SUM(is_returned) as total_returns,
    ROUND(AVG(is_returned::numeric * 100), 2) as return_rate_pct,
    COUNT(DISTINCT product_category) as categories_ordered,
    COUNT(DISTINCT CASE WHEN is_returned = 1 THEN product_category END) as categories_returned,
    ROUND(SUM(refund_amount)::numeric, 2) as total_refund_taken,
    ROUND(AVG(price)::numeric, 2) as avg_order_value,
    ROUND(AVG(rating)::numeric, 2) as avg_rating,
    MODE() WITHIN GROUP (ORDER BY return_reason) as top_return_reason,
    MODE() WITHIN GROUP (ORDER BY product_category) as most_ordered_category
FROM order_details
GROUP BY customer_unique_id
HAVING COUNT(DISTINCT order_id) >= 3
AND AVG(is_returned::numeric) >= 0.5
ORDER BY total_refund_taken DESC
LIMIT 20;
/*
RESULT  : Customers with 50-75% return rate | "Changed Mind" & "Defective" top reasons
INSIGHT : Repeat customers with high return rate — systematic refund abuse pattern
IMPACT  : Top 20 suspicious customers — R$4,000+ combined refund taken
*/

-- ================================================================
-- Q12: FASHION RETURN REASON INSIGHTS — WARDROBING DETECTION
-- WHY : Fashion fraud pattern — buy, use, return
-- ================================================================
SELECT 
    product_category,
    return_reason,
    COUNT(*) as total_returns,
    ROUND(AVG(price)::numeric, 2) as avg_price,
    ROUND(AVG(rating)::numeric, 2) as avg_rating,
    ROUND(SUM(refund_amount)::numeric, 2) as total_refund_loss,
    ROUND(AVG(days_to_return)::numeric, 2) as avg_days_to_return
FROM order_details
WHERE is_returned = 1
AND product_category ILIKE '%fashion%'
OR (is_returned = 1 AND product_category ILIKE '%cloth%')
GROUP BY product_category, return_reason
ORDER BY total_returns DESC;
/*
RESULT  : Fashion Bags — Wrong Item 104 (R$7,191) | Defective 102 | Changed Mind 94 (R$6,122)
INSIGHT : "Changed Mind" after avg 227 days — classic wardrobing (used for events!)
IMPACT  : Fashion category R$40,000+ total refund loss — highest in platform
*/

-- ================================================================
-- Q13: RETURN REASON PERFORMANCE BY CATEGORY
-- WHY : Har category mein return reason ka % breakdown
-- WINDOW FUNCTION : SUM() OVER (PARTITION BY)
-- ================================================================
SELECT 
    product_category,
    return_reason,
    COUNT(*) as total_returns,
    ROUND(AVG(price)::numeric, 2) as avg_price,
    ROUND(AVG(rating)::numeric, 2) as avg_rating,
    ROUND(SUM(refund_amount)::numeric, 2) as total_refund_loss,
    ROUND(AVG(days_to_return)::numeric, 2) as avg_days_to_return,
    ROUND(COUNT(*)::numeric / SUM(COUNT(*)) OVER (PARTITION BY product_category) * 100, 2) as reason_pct
FROM order_details
WHERE is_returned = 1
AND product_category IN (
    SELECT product_category FROM order_details
    GROUP BY product_category
    HAVING AVG(is_returned::numeric * 100) > 22
)
GROUP BY product_category, return_reason
ORDER BY product_category, total_returns DESC;
/*
RESULT  : Construction Tools — "Wrong Item" 34.88% | Diapers "Wrong Item" 44.44%
INSIGHT : 3 problem types identified — Fraud (Changed Mind) | Seller (Not as Described) | Ops (Wrong Item)
IMPACT  : Each problem needs different solution — not one-size-fits-all policy
*/

-- ================================================================
-- Q14: SELLER RETURN & REFUND PERFORMANCE
-- WHY : Konsa seller sabse zyada returns cause kar raha hai
-- ================================================================
SELECT 
    od.seller_id,
    COUNT(*) as total_orders,
    SUM(od.is_returned) as total_returns,
    ROUND(AVG(od.is_returned::numeric * 100), 2) as return_rate_pct,
    ROUND(SUM(od.refund_amount)::numeric, 2) as total_refund_loss,
    ROUND(AVG(od.rating)::numeric, 2) as avg_rating,
    MODE() WITHIN GROUP (ORDER BY od.return_reason) as top_return_reason,
    MODE() WITHIN GROUP (ORDER BY od.product_category) as top_category
FROM order_details od
GROUP BY od.seller_id
HAVING COUNT(*) > 50
ORDER BY return_rate_pct DESC
LIMIT 15;
/*
RESULT  : Seller 048c27 — 39.22% return rate (Fashion Shoes) R$1,310 loss
          Seller cce6ab — 33.33% (Bed Bath Table) R$1,419 loss
          Seller 7ea5bf — 32.69% (Baby Products) R$2,238 loss — HIGHEST LOSS
INSIGHT : Top 5 sellers ka return rate 32-39% vs industry avg 20.60%
IMPACT  : These 5 sellers responsible for R$8,000+ avoidable refund loss
RECOMMENDATION : Suspend sellers above 35% | Warning above 25% | Monthly seller scorecard
*/

-- ================================================================
-- Q15: CATEGORY RETURN PERFORMANCE SUMMARY (ALL CATEGORIES)
-- WHY : Complete platform view — saari categories ka summary
-- ================================================================
SELECT 
    product_category,
    total_orders,
    total_returns,
    return_rate_pct,
    total_refund_loss,
    avg_rating,
    ROUND((returns_0_50::numeric / NULLIF(orders_0_50,0) * 100), 2) as return_pct_0_50,
    ROUND((returns_50_200::numeric / NULLIF(orders_50_200,0) * 100), 2) as return_pct_50_200,
    ROUND((returns_200_plus::numeric / NULLIF(orders_200_plus,0) * 100), 2) as return_pct_200_plus
FROM (
    SELECT 
        product_category,
        COUNT(*) as total_orders,
        SUM(is_returned) as total_returns,
        ROUND(AVG(is_returned::numeric * 100), 2) as return_rate_pct,
        ROUND(SUM(refund_amount)::numeric, 2) as total_refund_loss,
        ROUND(AVG(rating)::numeric, 2) as avg_rating,
        COUNT(CASE WHEN price < 50 THEN 1 END) as orders_0_50,
        SUM(CASE WHEN price < 50 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_0_50,
        COUNT(CASE WHEN price >= 50 AND price < 200 THEN 1 END) as orders_50_200,
        SUM(CASE WHEN price >= 50 AND price < 200 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_50_200,
        COUNT(CASE WHEN price >= 200 THEN 1 END) as orders_200_plus,
        SUM(CASE WHEN price >= 200 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_200_plus
    FROM order_details
    GROUP BY product_category
    HAVING COUNT(*) > 100
) sub
ORDER BY return_rate_pct DESC;
/*
RESULT  : 54 categories | Construction Tools highest return rate | Small Appliances R$10,019 loss
INSIGHT : High return rate consistent across all categories — not isolated incidents
IMPACT  : Platform-wide 20.60% return rate — industry benchmark is 8-10%
*/

-- ================================================================
-- Q16: MONTHLY REVENUE LEAKAGE & REFUND TREND
-- WHY : Time series mein revenue loss track karna
-- WINDOW FUNCTION : LAG() — month over month change
-- ================================================================
SELECT 
    order_month,
    total_orders,
    ROUND(total_revenue::numeric, 2) as total_revenue,
    ROUND(total_refund::numeric, 2) as total_refund,
    ROUND(net_revenue::numeric, 2) as net_revenue,
    return_rate_pct,
    loss_pct,
    ROUND(total_refund::numeric - LAG(total_refund::numeric) 
          OVER (ORDER BY order_month), 2) as refund_change_vs_last_month
FROM revenue_leakage
ORDER BY order_month;
/*
RESULT  : Nov 2017 — R$1,13,402 refund (HIGHEST) | R$39,703 spike vs October
          Consistent 9.3-10.5% monthly revenue loss
INSIGHT : Festival season mein 40% refund spike — customers exploit lenient policies
IMPACT  : November alone — R$45,000 extra loss vs normal months
RECOMMENDATION : Festival season mein return window 30 days se 7 days kar do
                 Discounted items — exchange only, no refund
*/

-- ================================================================
-- PROJECT SUMMARY
-- ================================================================
/*
OVERALL FINDINGS:
=================
1. Total Revenue Loss  : R$1,543,899 (9.74% of revenue)
2. Return Rate         : 20.60% — 2x industry benchmark of 8-10%
3. Worst Category      : Fashion — 31.25% (Wardrobing Fraud)
4. Worst Price Band    : R$200+ Fashion Shoes — 36.36% return
5. Worst Seller        : 39.22% return rate vs 20% average
6. Worst Month         : November 2017 — festival season spike
7. Main Return Reasons : Wrong Item | Changed Mind | Not as Described

SQL TECHNIQUES USED:
====================
- RANK() Window Function
- NTILE() Window Function  
- LAG() Window Function
- SUM() OVER (PARTITION BY)
- CASE WHEN (Pivot Tables)
- CTEs (Common Table Expressions)
- HAVING clause
- MODE() Aggregate Function
- NULLIF() for division safety
- ILIKE for pattern matching

BUSINESS RECOMMENDATIONS:
==========================
1. Fashion items     → Photo proof required for returns
2. R$200+ items      → Video unboxing required
3. Top 5 sellers     → Immediate suspension/warning
4. Festival season   → Reduce return window to 7 days
5. Food category     → No returns policy
6. Repeat returners  → Flag and review manually

ESTIMATED RECOVERY  : R$5,16,169+ if recommendations implemented
*/
