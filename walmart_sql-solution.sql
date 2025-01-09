-- Walmart sale data analyze project

-- create DB

create database walmart_sale;
use walmart_sale;

select * from walmart_sale.wal_saledata limit 5;

-- Walmart Project Queries - MySQL

select * from walmart_sale.wal_saledata;

-- DROP TABLE walmart;

-- DROP TABLE walmart;

-- Count total records
select count(*) from walmart_sale.wal_saledata;

-- Count payment methods and number of transactions by payment method
select payment_method,
count(*) No_Payments from walmart_sale.wal_saledata
group by payment_method;

-- Count distinct branches
select count(distinct branch) from walmart_sale.wal_saledata;

-- Find the minimum quantity sold
select min(quantity) from walmart_sale.wal_saledata;

-- Business Problem Q1: Find different payment methods, number of transactions, and quantity sold by payment method
select payment_method,
count(*) as number_of_transactions,
sum(quantity) as quantity
from walmart_sale.wal_saledata
group by payment_method;


-- Project Question #2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating

with cte as(select branch,category,avg(rating) avg_rating
from walmart_sale.wal_saledata
group by branch,category)
select branch,category,avg_rating from (
select *, row_number() over(partition by branch order by avg_rating desc)rn from cte) a
where rn = 1;

-- Q3: Identify the busiest day for each branch based on the number of transactions
with cte as (
select branch,
dayname(str_to_date(date,'%d/%m/%Y')) as Day_name, 
count(*) no_transactions
from walmart_sale.wal_saledata
group by branch,Day_name)

select branch,Day_name,no_transactions from(
select *,row_number() over(partition by branch order by no_transactions desc)rn from cte)a
where rn =1;

-- Q4: Calculate the total quantity of items sold per payment method

select payment_method as payment, sum(quantity)
from walmart_sale.wal_saledata
group by payment_method;

-- Q5: Determine the average, minimum, and maximum rating of categories for each city

select City, category,avg(rating) avg_rating, min(rating) min_rating, max(rating) max_rating
from walmart_sale.wal_saledata
group by City,category;

-- Q6: Calculate the total profit for each category

select category,
sum(unit_price * quantity * profit_margin) as profit
from walmart_sale.wal_saledata
group by category
order by profit desc;

-- Q7: Determine the most common payment method for each branch

with cte as (select branch, payment_method, count(payment_method)payment_mode
from walmart_sale.wal_saledata
group by branch,payment_method)

select branch,payment_method from(
select *, row_number() over(partition by branch order by payment_mode desc)rn from cte) a
where rn=1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts

select branch,hour(time) Hours, count(*) no_invoices,
case when time < 12 then 'Morning' 
when time between 12 and 17 then 'Noon'
else 'Evening' end as Shift
from walmart_sale.wal_saledata
group by branch,Hours,Shift;


-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)

with cte_2022 as (
select branch, 
sum(total) revenue
from walmart_sale.wal_saledata
where Year(str_to_date(date, '%d/%m/%Y')) = 2022
group by branch),

cte_2023 as(
select branch, 
sum(total) revenue
from walmart_sale.wal_saledata
where Year(str_to_date(date, '%d/%m/%Y')) = 2023
group by branch)

select c_22.branch,
c_22.revenue as revenue_2022,
c_23.revenue as revenue_2023,
round((c_22.revenue - c_23.revenue)/c_22.revenue * 100,2) as Ratio
from cte_2022 c_22
join cte_2023 c_23 on c_22.branch = c_23.branch
where c_22.revenue > c_23.revenue
order by Ratio desc limit 5;