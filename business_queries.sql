
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
