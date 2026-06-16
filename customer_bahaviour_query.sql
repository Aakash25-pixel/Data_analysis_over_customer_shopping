select * from customer_shopping_behavior 
-- Total revenue generated from male vs female customers 
select gender, sum(purchase_amount) as total_revenue from dbo.customer_shopping_behavior 
group by gender 
-- which customers used the discount amounts still spent more than average amount on their purchases
select customer_id, purchase_amount  from dbo.customer_shopping_behavior 
where discount_applied = 'Yes' and purchase_amount > (select avg(purchase_amount) from dbo.customer_shopping_behavior)
-- Top 5 products with the highest average review rating 
select top 5 item_purchased, avg(review_rating) as average_rating from dbo.customer_shopping_behavior 
group by item_purchased  
order by average_rating desc 
-- avrg purchase amount between standard and express shipping types
select shipping_type,avg(purchase_amount) as average_purchase_amount from dbo.customer_shopping_behavior
where shipping_type in ('Standard', 'Express')
group by shipping_type 
-- Do subscribed customers spend more than non_subscribed customers ? comapare spend and total revenue generated from both groups
SELECT
    subscription_status, count(customer_id) as total_customers,
    ROUND(AVG(CONVERT(DECIMAL(10,2), purchase_amount)), 2) as average_purchase_amount,
    sum(purchase_amount) as total_revenue
FROM dbo.customer_shopping_behavior
GROUP BY subscription_status;
-- Top 5 products which have highest percentage of purachse when discount is applied
SELECT TOP 5
    item_purchased,
    ROUND(
        SUM(
            CASE
                WHEN discount_applied = 'Yes' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS percentage_with_discount
FROM dbo.customer_shopping_behavior
GROUP BY item_purchased
order by percentage_with_discount desc;
-- segment customers new ,returning and loyal based on their previous purchases and frequency of purchases
with customer_type as (
    select 
        customer_id,
        case 
            when previous_purchases = 1 then 'New'
            when previous_purchases between 2 and 10   then 'Returning'
          else 'Loyal'
        end as customer_segment
    from dbo.customer_shopping_behavior
) 
select customer_segment, count(customer_id) as total_customers from customer_type
group by customer_segment
-- Top 3 most purchased product from each category
WITH RankedProducts AS (
    SELECT 
        category,
        item_purchased,
        COUNT(*) AS purchase_count,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(*) DESC) AS item_rank
    FROM dbo.customer_shopping_behavior
    GROUP BY category, item_purchased
)   
select item_rank, category, item_purchased, purchase_count from RankedProducts
where item_rank <= 3  

-- revenue contribution of each age group 

SELECT
    age_group,
    SUM(purchase_amount) AS total_revenue
FROM dbo.customer_shopping_behavior
GROUP BY age_group;