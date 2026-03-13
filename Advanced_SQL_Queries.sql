
set search_path to asssignment ;
select table_name from information_schema.tables where table_schema ='assignment';
select * from assignment.customers_2;
select * from assignment.inventory;
select * from assignment.products;
select * from assignment.sales;
show search_path;
-- 51. Which customers have spent more than the average spending of all customers?
SELECT c.first_name,
       c.last_name,
       s.total_amount
FROM assignment.customers_2 c
JOIN assignment.sales s
ON c.customer_id = s.customer_id
WHERE s.total_amount >
      (SELECT AVG(total_amount)
       FROM assignment.sales);


-- 52. Which products are priced higher than the average price of all products?
select product_name,price   
from assignment.products 
where price > (select avg(price)as avg_price from assignment.products);
-- 53. Which customers have never made a purchase?
select c.first_name,c.last_name,c.customer_id  
from assignment.customers_2 c 
where not exists 
(select 1 from assignment.sales s 
where s.customer_id = c.customer_id );

-- 54. Which products have never been sold?
select p.product_name,p.product_id
from assignment.products p  
where not exists (select 1 from assignment.sales s   
where p.product_id = s.product_id);
-- 55. Which customer made the single most expensive purchase?
select c.first_name,c.last_name,(select max(s.total_amount )from assignment.sales  s
where s.customer_id = c.customer_id
group  by s.total_amount 
order  by max desc)
from assignment.customers_2 c ;

-- 56. Which products have total sales greater than the average total sales across all products?
select * from (select p.product_name,AVG(s.total_amount) as avg_amount 
from assignment.products p 
join assignment.sales s on p.product_id = s.product_id 
group by p.product_name 
order by avg_amount desc );

-- 57. Which customers registered earlier than the average registration date?
select first_name,last_name,registration_date
from assignment.customers_2
where registration_date < (select TO_TIMESTAMP AVG(extract(EPOCH from registration_date )))
from assignment.customers_2);
-- 58. Which products have a price higher than the average price within their own category?
select * from assignment.products;
select product_name,price ,category  
from assignment.products 
where price > (select avg(price)as avg_price from assignment.products)
group by category ,price,product_name;
-- 59. Which customers have spent more than the customer with ID = 10?
select customer_id, SUM(total_amount) as sum_amount 
from assignment.sales 
group by customer_id 
having sum(total_amount) >(select sum(total_amount ) from assignment.sales
where customer_id = 10);
-- 60. Which products have total quantity sold greater than the overall average quantity sold?
select p.product_name  ,s.quantity_sold ,AVG(s.quantity_sold )
from assignment.products p 
join assignment.sales s on p.product_id = s.product_id  
where s.quantity_sold  >(select AVG(s.quantity_sold) from assignment.sales s )
group by p.product_name,s.quantity_sold;


-- =====================================================
-- COMMON TABLE EXPRESSIONS (CTEs)
-- =====================================================

-- 61. Create an intermediate result that calculates the total amount spent by each customer,
--     then determine which customers are the top 5 highest spenders.
with total_amount_spent as (select c.first_name,c.last_name,s.total_amount
from assignment.customers_2 c 
join assignment.sales s on c.customer_id = c.customer_id
order by s.total_amount desc 
limit 5 )
select *  from total_amount_spent;
-- 62. Create an intermediate result that calculates total quantity sold per product,
--     then determine which products are the top 3 most sold.
with total_quantity_sold as (select s.quantity_sold ,p.product_name 
from assignment.sales s 
join assignment.products p on s.product_id = p.product_id 
order by s.quantity_sold 
limit 3 )
select * from total_quantity_sold;
-- 63. Create an intermediate result showing total sales per product category,
--     then determine which category generates the highest revenue.
with total_sales as (select p.product_name,p.category,max(s.total_amount) 
from assignment.products p 
join assignment.sales s on p.product_id = s.product_id
group by p.product_name,p.category 
order by max(s.total_amount)desc)
select * from total_sales;
-- 64. Create an intermediate result that calculates the number of purchases per customer,
--     then identify customers who purchased more than twice.
with purchase_per_customer as (select s.customer_id ,COUNT(*) as count_purchase 
from assignment.sales s 
group by s.customer_id)
select * from purchase_per_customer
where count_purchase > 2 ;

-- 65. Create an intermediate result that calculates the total quantity sold per product,
--     then determine which products sold more than the average quantity sold.
with total_quantity as (select p.product_name ,SUM(s.quantity_sold )as sum_quantity ,AVG(s.quantity_sold) as avg_quantity
from assignment.sales s 
join assignment.products p on  s.product_id = p.product_id 
group by p.product_name)
select * from total_quantity 
where sum_quantity > avg_quantity ;

-- 66. Create an intermediate result that calculates total spending per customer,
--     then determine which customers spent more than the average spending.
with total_spending as (select SUM(s.total_amount)as sum_amount ,AVG(s.total_amount )as avg_amount ,c.first_name,c.last_name
from assignment.sales s  
join assignment.customers_2 c on s.customer_id = c.customer_id
group by c.first_name ,c.last_name)
select * from total_spending
where sum_amount > avg_amount ;
-- 67. Create an intermediate result that calculates total revenue per product,
--     then list the products ordered from highest revenue to lowest.
with total_revenue as (select p.product_name,s.quantity_sold,p.price,p.price*s.quantity_sold as revenue
from sales s  
join products p on s.product_id = p.product_id )
select * from total_revenue 
order by revenue desc;

-- 68. Create an intermediate result showing monthly sales totals,
--     then determine which month had the highest revenue.
with monthly_sales as (select extract( month from sale_date),sum(total_amount) as total_amount 
from sales 
group by extract(month from sale_date))
select * from monthly_sales 
order by total_amount desc;

-- 69. Create an intermediate result that calculates the number of sales per product,
--     then determine which products were purchased by more than three customers.
with total_sales as (select p.product_name,SUM(s.quantity_sold), c.first_name,c.last_name,COUNT(*)as sales_per_customer 
from sales s  
join products p  on s.product_id = s.product_id 
join customers_2 c on s.customer_id = c.customer_id 
group by p.product_name,c.first_name,c.last_name )
select * from total_sales 
where sales_per_customer > 3;
-- 70. Create an intermediate result showing total quantity sold per product,
--     then identify products that sold less than the average quantity sold.
with total_sales_per_product as (select p.product_name,SUM(s.quantity_sold )as sum_quantity,AVG(s.quantity_sold)as avg_quantity
from sales s 
join products p on s.product_id = p.product_id 
group by p.product_name )
select * from total_sales_per_product 
where sum_quantity<avg_quantity;


-- =====================================================
-- WINDOW FUNCTION QUESTIONS
-- =====================================================

-- 71. Rank customers based on the total amount they have spent.
select total_amount ,customer_id ,
RANK() over (order by total_amount desc )
from sales ;
-- 72. Rank products based on total quantity sold.
select product_id,SUM(s.quantity_sold),rank() OVER(order by SUM(s.quantity_sold)desc)
from assignment.sales s 
group by product_id ;
-- 73. Identify the 3rd highest spending customer.
select customer_id ,total_amount from(select customer_id,total_amount,rank()
over (order by total_amount desc ) as spending_category from sales)  
where spending_category = 3;
-- 74. Identify the 2nd most expensive product.
select product_name,price from(select product_name,price ,RANK() over (order by price desc)as price_category
from products )
where price_category = 2;
-- 75. Show the ranking of products within each category based on price.
select product_name,price ,category ,DENSE_RANK() OVER(partition by category   order by price desc )
from products;

-- 76. Show the ranking of customers based on the number of purchases they made.
select customer_id ,quantity_sold ,RANK() over (order by quantity_sold desc )
from sales ;
-- 77. Show the running total of sales amounts ordered by sale_date.
select total_amount, sale_date,SUM(total_amount) over 
(order by sale_date) as running_total_amount 
from sales;
-- 78. Show the previous sale amount for each sale ordered by sale_date.
select total_amount,sale_date ,lag(total_amount)over(order by sale_date)
from sales;
-- 79. Show the next sale amount for each sale ordered by sale_date.
select total_amount,sale_date ,lead(total_amount)over(order by sale_date)
from sales;
-- 80. Divide customers into 4 groups based on total spending.

select customer_id ,total_amount ,NTILE(4)OVER(order by total_amount desc)
from sales;
-- =====================================================
-- ADVANCED ANALYTICAL QUESTIONS
-- =====================================================

-- 81. Which customers bought products in more than one category?
select c.first_name,c.last_name,p.product_name,COUNT (distinct p.category)
from products p    
join sales s   on p.product_id = s.product_id 
join customers_2 c on s.customer_id = c.customer_id 
group by c.first_name,c.last_name,p.product_name 
having count(distinct p.category )> 1;
-- 82. Which customers purchased products within 7 days of registering?
select c.first_name,c.last_name,s.sale_date,c.registration_date
from sales s 
join customers_2 c on s.customer_id = c.customer_id 
where (extract (day from s.sale_date  )- (extract (day from c.registration_date)<= 7;
show search_path;

-- 83. Which products have lower stock remaining than the average stock quantity?
select product_name ,stock_quantity 
from assignment.products 
where stock_quantity < (select avg(stock_quantity )from assignment.products);
-- 84. Which customers purchased the same product more than once?
select c.first_name,c.last_name,p.product_name,COUNT (distinct p.product_name)
from assignment.products p    
join assignment.sales s   on p.product_id = s.product_id 
join assignment.customers_2 c on s.customer_id = c.customer_id 
group by c.first_name,c.last_name,p.product_name 
having count(distinct p.product_name )> 1;
-- 85. Which product categories generated the highest total revenue?
select product_name ,MAX(revenue),category 
from(select p.product_name,p.category, p.price,s.quantity_sold ,s.quantity_sold*p.price as revenue
from assignment.sales s 
join assignment.products p on s.product_id = p.product_id )
group by product_name, category
order by max(revenue)desc;
-- 86. Which products are among the top 3 most sold products?
select p.product_name,s.quantity_sold 
from assignment.sales s 
join assignment.products p on s.product_id =p.product_id 
order by s.quantity_sold desc
limit 3;
-- 87. Which customers purchased the most expensive product?
select first_name,last_name,max 
from (select c.first_name,c.last_name ,p.price ,p.product_name ,max(s.total_amount)
from assignment.sales s  
join assignment.products p on s.product_id = p.product_id 
join assignment.customers_2 c on s.customer_id = c.customer_id
group by c.first_name,c.last_name,p.price,p.product_name 
order by max(s.total_amount) desc)
limit 1;
-- 88. Which products were purchased by the highest number of unique customers?
select s.customer_id ,p.product_name ,COUNT(distinct s.customer_id) as unique_customers
from assignment.sales s    
join assignment.products p on s.product_id = p.product_id 
group by s.customer_id,p.product_name 
order by unique_customers desc
limit 1 ;
-- 89. Which customers made purchases above the average sale amount?
select customer_id ,total_amount     
from assignment.sales 
where total_amount > (select avg(total_amount )from assignment.sales)
order by total_amount desc;
-- 90. Which customers purchased more products than the average quantity purchased per customer?
select s.customer_id ,p.product_name,s.quantity_sold 
from assignment.sales s  
join assignment.products p on s.product_id = p.product_id 
where s.quantity_sold > (select avg(quantity_sold) from assignment.sales s )
group by s.customer_id,p.product_name,s.quantity_sold ;



-- =====================================================
-- ADVANCED WINDOW + ANALYTICAL PROBLEMS
-- =====================================================

-- 91. Which customers rank in the top 10% of spending?
select customer_id ,total_amount, ntile(10)over (order by SUM(total_amount )desc )
from assignment.sales 
group by customer_id ,total_amount;
-- 92. Which products contribute to the top 50% of total revenue?
select SUM(s.total_amount),p.product_name ,NTILE(2)over 
(order by s.total_amount desc )
from assignment.sales s  
join assignment.products p on s.product_id = p.product_id 
group by  p.product_name,s.total_amount;
-- 93. Which customers made purchases in consecutive months?
select customer_id,
extract(year from sale_date) as sale_year,
extract(month from sale_date) as sale_month
from assignment.sales
sum(total_amount)
group by customer_id,extract(year from sale_date),extract(month from sale_date)
order by customer_id,sale_year,sale_month asc;

-- 94. Which products experienced the largest difference between stock quantity and total quantity sold?
select p.product_name,p.stock_quantity,SUM(s.quantity_sold),p.stock_quantity-SUM(s.quantity_sold)as total_diff
from assignment.sales s  
join assignment.products p on s.product_id = p.product_id 
group by p.product_name,p.stock_quantity 
order by total_diff desc;
-- 95. Which customers have spending above the average spending of their membership tier?
select c.first_name,c.last_name,c.membership_status  ,s.total_amount
from assignment.sales s  
join assignment.customers_2 c on s.customer_id = c.customer_id 
where s.total_amount >(select avg(total_amount)from assignment.sales);


-- 96. Which products have higher sales than the average sales within their category?
select p.product_name ,p.category,s.total_amount 
from assignment.sales s   
join assignment.products p on s.product_id = p.product_id 
where s.total_amount >(select avg(total_amount)from assignment.sales)
group by p.product_name,p.category,s.total_amount
order by total_amount desc;
-- 97. Which customer made the largest single purchase relative to their total spending?
with customer_spending as (select customer_id,sum(quantity_sold)as sum_quantity,
sum(total_amount)as total_spent 
from assignment.sales   
group by customer_id )
select customer_id ,sum_quantity,total_spent ,(sum_quantity/total_spent)as ratio 
from customer_spending 
order by ratio desc ;
-- 98. Which products rank among the top 3 most sold products within each category?
select p.product_name,p.category,SUM(s.quantity_sold)
from assignment.sales s 
join assignment.products p on s.product_id = p.product_id 
group by p.product_name,p.category 
order by p.category,p.product_name;


-- 99. Which customers are tied for the highest total spending?
select customer_id,max(total_amount),RANK()OVER(order by total_amount desc)
from assignment.sales s 
group by customer_id ,s.total_amount;
-- 100. Which products generated sales every year present in the dataset?
select product_id ,total_amount,extract(year from sale_date)
from assignment.sales  
order by extract(year from sale_date);
