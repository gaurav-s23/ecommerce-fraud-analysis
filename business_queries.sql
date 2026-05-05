
##  Overall Business  Overview

SELECT 
    COUNT(*) as total_orders,
    ROUND(SUM(total_revenue)::numeric, 2) as total_revenue,
    ROUND(SUM(refund_amount)::numeric, 2) as total_refund_loss,
    ROUND(SUM(net_revenue)::numeric, 2) as net_revenue,
    ROUND(AVG(is_returned::numeric * 100), 2) as return_rate_pct,
    ROUND((SUM(refund_amount) / SUM(total_revenue) * 100)::numeric, 2) as loss_pct
FROM order_details;



##  Category wise Return 

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


##   High Risk Refund Analysis Quartiles


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

## Price Range Refund preformance


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



## Category return Rate rate  by price range

SELECT 
    product_category,
    COUNT(*) as total_orders,
    
    -- 0 to 50
    COUNT(CASE WHEN price < 50 THEN 1 END) as orders_0_50,
    SUM(CASE WHEN price < 50 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_0_50,
    
    -- 50 to 100
    COUNT(CASE WHEN price >= 50 AND price < 100 THEN 1 END) as orders_50_100,
    SUM(CASE WHEN price >= 50 AND price < 100 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_50_100,
    
    -- 100 to 200
    COUNT(CASE WHEN price >= 100 AND price < 200 THEN 1 END) as orders_100_200,
    SUM(CASE WHEN price >= 100 AND price < 200 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_100_200,
    
    -- 200 to 500
    COUNT(CASE WHEN price >= 200 AND price < 500 THEN 1 END) as orders_200_500,
    SUM(CASE WHEN price >= 200 AND price < 500 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_200_500,
    
    -- 500 above
    COUNT(CASE WHEN price >= 500 THEN 1 END) as orders_500_plus,
    SUM(CASE WHEN price >= 500 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_500_plus,
    
    -- Total returns
    SUM(is_returned) as total_returns,
    ROUND(AVG(is_returned::numeric * 100), 2) as overall_return_rate_pct

FROM order_details
GROUP BY product_category
ORDER BY total_returns DESC
LIMIT 20;



## Return rate by price band (Top categories)

SELECT 
    product_category,
    total_orders,
    
    -- Return rate har price range mein
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


## high Return Rate by product category

SELECT 
    product_category,
    COUNT(*) as total_orders,
    SUM(is_returned) as total_returns,
    ROUND(AVG(is_returned::numeric * 100), 2) as return_rate_pct,
    ROUND(SUM(refund_amount)::numeric, 2) as total_refund_loss,
    ROUND(AVG(rating)::numeric, 2) as avg_rating,

    -- Price range breakdown
    COUNT(CASE WHEN price < 50 THEN 1 END) as orders_0_50,
    SUM(CASE WHEN price < 50 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_0_50,

    COUNT(CASE WHEN price >= 50 AND price < 200 THEN 1 END) as orders_50_200,
    SUM(CASE WHEN price >= 50 AND price < 200 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_50_200,

    COUNT(CASE WHEN price >= 200 THEN 1 END) as orders_200_plus,
    SUM(CASE WHEN price >= 200 AND is_returned = 1 THEN 1 ELSE 0 END) as returns_200_plus

FROM order_details
GROUP BY product_category
HAVING AVG(is_returned::numeric * 100) > 22  -- sirf high return rate wali
ORDER BY return_rate_pct DESC;




## category return and refund perfomance summary

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



### return fraud by product category (same and in two day)


-- Same Day & 2 Day Return Fraud by Category
SELECT 
    product_category,
    COUNT(*) as total_orders,
    SUM(is_returned) as total_returns,
    
    -- Same day return (0-1 din)
    COUNT(CASE WHEN days_to_return >= 0 
          AND days_to_return <= 1 
          AND is_returned = 1 THEN 1 END) as same_day_returns,
    
    -- 2 din ke andar
    COUNT(CASE WHEN days_to_return > 1 
          AND days_to_return <= 2 
          AND is_returned = 1 THEN 1 END) as two_day_returns,

    ROUND(AVG(rating)::numeric, 2) as avg_rating,
    ROUND(SUM(refund_amount)::numeric, 2) as total_refund_loss,
    
    -- Fraud % 
    ROUND((COUNT(CASE WHEN days_to_return <= 2 
          AND is_returned = 1 THEN 1 END)::numeric / 
          NULLIF(SUM(is_returned), 0) * 100), 2) as quick_return_fraud_pct

FROM order_details
GROUP BY product_category
HAVING COUNT(*) > 200
ORDER BY quick_return_fraud_pct DESC
LIMIT 15;


## coustomer return_fraud signals


SELECT 
    customer_unique_id,
    COUNT(DISTINCT order_id) as total_orders,
    SUM(is_returned) as total_returns,
    ROUND(AVG(is_returned::numeric * 100), 2) as return_rate_pct,
    COUNT(DISTINCT product_category) as categories_ordered,
    COUNT(DISTINCT CASE WHEN is_returned = 1 
          THEN product_category END) as categories_returned,
    ROUND(SUM(refund_amount)::numeric, 2) as total_refund_taken,
    ROUND(AVG(price)::numeric, 2) as avg_order_value,
    ROUND(AVG(rating)::numeric, 2) as avg_rating,
    MODE() WITHIN GROUP (ORDER BY return_reason) as top_return_reason,
    MODE() WITHIN GROUP (ORDER BY product_category) as most_ordered_category
FROM order_details
GROUP BY customer_unique_id
HAVING COUNT(DISTINCT order_id) >= 3  -- kam se kam 3 orders
AND AVG(is_returned::numeric) >= 0.5  -- 50%+ return rate
ORDER BY total_refund_taken DESC
LIMIT 20;



## fashion return reason insights


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


## return reason performance by category


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
    SELECT product_category
    FROM order_details
    GROUP BY product_category
    HAVING AVG(is_returned::numeric * 100) > 22
)
GROUP BY product_category, return_reason
ORDER BY product_category, total_returns DESC;


##  seller return & refund insights

    SELECT 
    seller_id,
    seller_city,
    seller_state,
    COUNT(*) as total_orders,
    SUM(is_returned) as total_returns,
    ROUND(AVG(is_returned::numeric * 100), 2) as return_rate_pct,
    ROUND(SUM(refund_amount)::numeric, 2) as total_refund_loss,
    ROUND(AVG(rating)::numeric, 2) as avg_rating,
    MODE() WITHIN GROUP (ORDER BY return_reason) as top_return_reason,
    MODE() WITHIN GROUP (ORDER BY product_category) as top_category
FROM order_details
GROUP BY seller_id, seller_city, seller_state
HAVING COUNT(*) > 50
ORDER BY return_rate_pct DESC
LIMIT 15;


## seller return & refund performance 

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



## monthly revenue Leakage & refund trends


SELECT 
    order_month,
    total_orders,
    ROUND(total_revenue::numeric, 2) as total_revenue,
    ROUND(total_refund::numeric, 2) as total_refund,
    ROUND(net_revenue::numeric, 2) as net_revenue,
    return_rate_pct,
    loss_pct,
    -- Month over month loss change
    ROUND(total_refund::numeric - LAG(total_refund::numeric) 
          OVER (ORDER BY order_month), 2) as refund_change_vs_last_month
FROM revenue_leakage
ORDER BY order_month;
