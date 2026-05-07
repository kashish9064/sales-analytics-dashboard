use sales_analytics;
-- ================================================
-- Show only days that earned MORE than the yearly average for their year.
-- Q15: SUBQUERY — Days Above Their Year's Average
-- Find overperforming days within each year
-- ================================================
select
s.sale_date as date,
s.sale_year as year,
s.sale_month as month,
s.day_name as day,
round(s.total_rev,2) as daily_revenue,
round(yearly_avg.avg_revenue,2) as year_avg_revenue,
round(s.total_rev-yearly_avg.avg_revenue,2) as above_avg_by,
s.top_product as best_product
from sales_data s 
join(select
sale_year,avg(total_rev) as avg_revenue
from sales_data
group by sale_year) as yearly_avg
on s.sale_year=yearly_avg.sale_year
where s.total_rev>yearly_avg.avg_revenue
order by s.sale_year,s.total_rev desc;
-- ================================================
-- Show each day's sales with the product reference details.
-- Q16: JOIN — Sales Data + Product Reference Table
-- Combines transaction data with master data
-- ================================================
select
s.sale_date as date,
s.sale_year as year,
p.product_name as product,
p.price as standard_price,
case p.product_id
when 1 then s.qty_p1
when 2 then s.qty_p2
when 3 then s.qty_p3
when 4 then s.qty_p4
end as units_sold,
case p.product_id
when 1 then s.rev_p1
when 2 then s.rev_p2
when 3 then s.rev_p3
when 4 then s.rev_p4
end as revenue
from sales_Data s
inner join product_reference p on 1=1
where s.sale_year=2020
order by s.sale_date,p.product_id
limit 40;
create table if not exists Product_reference(
Product_Id int not null,
Product_name varchar(20) not null,
Price decimal(8,4) not null,
Rev_Column Varchar(10) not null,
Qty_Column varchar(10) not null,
primary key (product_id))
engine=innodb
default charset=utf8mb4
comment='product master refernce table';
INSERT INTO Product_Reference VALUES
(1, 'Product 1', 3.1700, 'rev_P1', 'qty_P1'),
(2, 'Product 2', 6.3400, 'rev_P2', 'qty_P2'),
(3, 'Product 3', 5.4200, 'rev_P3', 'qty_P3'),
(4, 'Product 4', 7.1300, 'rev_P4', 'qty_P4');
SELECT * FROM Product_Reference;
-- ================================================
-- For each year, show revenue vs the previous year side by side.
-- Q17: SELF JOIN — Year vs Previous Year
-- Compares current year to prior year in same row
-- ================================================
select
curr.sale_year as year,
round(curr.total_rev,2) as current_year_rev,
round(prev.total_rev,2) as previous_year_rev,
round(curr.total_rev-prev.total_rev,2) as revenue_difference,
round(((curr.total_rev-prev.total_rev)/prev.total_rev)*100,2) as growth_pct,
case
when curr.total_rev>prev.total_rev
then 'Growth Year'
when curr.total_rev<prev.total_rev
then 'Decline Year'
Else 'Flat Year'
end as performance
from
(select sale_year,sum(Total_rev) as total_rev
from sales_Data group by sale_year) as curr
left join(select sale_year,sum(total_rev) as total_rev
from sales_data group by sale_year) as prev
on curr.sale_year=prev.sale_year + 1
order by curr.sale_year;
-- ================================================
-- Classify each year's performance into business tiers.
-- Q18: ADVANCED CASE WHEN — Performance Tiers
-- Multi-condition business classification
-- ================================================
select
sale_year as year,
round(sum(total_rev),2) as total_revenue,
round(avg(total_rev),2) as average_Daily_rev,
count(*) as trading_Days,
case
        WHEN SUM(Total_Rev) >= 19000000
        THEN 'Platinum Year'
        WHEN SUM(Total_Rev) >= 18500000
        THEN 'Gold Year'
        WHEN SUM(Total_Rev) >= 18000000
        THEN 'Silver Year'
        WHEN SUM(Total_Rev) >= 10000000
        THEN 'Bronze Year'
        ELSE 'Incomplete Year'
end as Performance_Tier,
case
	   when count(*)=365 or count(*)=366
       then 'Full year'
       else 'Partial year'
end as Year_Completeness
from sales_Data
group by sale_year
order by sale_year;
-- ================================================
-- Find High revenue days that were NOT in Q1 and NOT on weekends.
-- Q19: COMPLEX WHERE CONDITIONS
-- AND, OR, IN, NOT IN, BETWEEN, LIKE combined
-- ================================================
select
sale_date as date,
sale_year as year,
sale_month as month,
day_name as day,
quarter as quarter,
round(total_rev,2) as revenue,
rev_category as category
from sales_Data
where
rev_category='High'
and quarter not in('Q1')
and day_name not in ('Saturday','Sunday')
and Sale_Year not in (2010,2023)
and sale_month in ('July','Aug','Sep','Oct','Nov','Dec')
order by Total_Rev Desc
limit 20;
-- ================================================
-- Format and manipulate text fields professionally.
-- Q20: STRING FUNCTIONS
-- TEXT manipulation in SQL
-- ================================================
select
 Sale_date                               AS Date,
    UPPER(Sale_Month)                       AS Month_Upper,
    LOWER(Day_Name)                         AS Day_Lower,
    LENGTH(Day_Name)                        AS Day_Name_Length,
    CONCAT(Sale_Month, ' ', Sale_Year)      AS Month_Year,
    CONCAT('FY-', Sale_Year)               AS Fiscal_Year_Label,
    LEFT(Day_Name, 3)                       AS Day_Short,
    REPLACE(Rev_Category, 'High', 'PREMIUM') AS Category_Renamed,
    LPAD(CAST(Month_No AS CHAR), 2, '0')   AS Month_Padded,
    TRIM('  High  ')                        AS Trimmed_Value
FROM Sales_Data
LIMIT 10;
-- ================================================
-- Extract and calculate date-based insights.
-- Q21: DATE FUNCTIONS
-- Extract parts of dates and calculate differences
-- ================================================
SELECT
    Sale_date                               AS Date,
    YEAR(Sale_date)                         AS Year_Extracted,
    MONTH(Sale_date)                        AS Month_Number,
    DAY(Sale_date)                          AS Day_Of_Month,
    DAYNAME(Sale_date)                      AS Day_Name,
    DAYOFWEEK(Sale_date)                    AS Day_Number_1to7,
    WEEKOFYEAR(Sale_date)                   AS Week_Number,
    QUARTER(Sale_date)                      AS Quarter_Number,
    DATEDIFF('2023-02-03', Sale_date)       AS Days_Since_Sale,
    DATE_FORMAT(Sale_date, '%d %M %Y')      AS Formatted_Date,
    DATE_FORMAT(Sale_date, '%W, %d %b %Y')  AS Full_Formatted_Date,
    LAST_DAY(Sale_date)                     AS Last_Day_Of_Month
FROM Sales_Data
WHERE Sale_Year = 2020
LIMIT 10;
-- ================================================
-- For each day show how it ranks within its own year.
-- Q22: CORRELATED SUBQUERY
-- Inner query references the outer query's current row
-- ================================================
SELECT
    s1.Sale_date                            AS Date,
    s1.Sale_Year                            AS Year,
    ROUND(s1.Total_Rev, 2)                 AS Daily_Revenue,
    (SELECT COUNT(*) + 1
        FROM Sales_Data s2
        WHERE s2.Sale_Year = s1.Sale_Year 
        AND s2.Total_Rev > s1.Total_Rev) AS Rank_In_Year,
     (SELECT COUNT(*)
        FROM Sales_Data s3
        WHERE s3.Sale_Year = s1.Sale_Year)  AS Total_Days_In_Year
FROM Sales_Data s1
WHERE s1.Sale_Year = 2020
ORDER BY s1.Total_Rev DESC;
-- ================================================
-- Q23: EXISTS CLAUSE
-- Check if a condition exists anywhere in data
-- ================================================
SELECT DISTINCT
    Sale_Year AS Year, 'Has 90K+ Day' AS Status
FROM
    Sales_Data s1
WHERE
    EXISTS( SELECT 
            1
        FROM
            Sales_Data s2
        WHERE
            s2.Sale_Year = s1.Sale_Year
                AND s2.Total_Rev >= 90000)
ORDER BY Sale_Year;
-- ================================================
-- Show monthly revenue with automatic subtotals per year and a grand total.
-- Q24: ROLLUP — Automatic Subtotals and Grand Total
-- Most professional reporting query in Step 10
-- ================================================
SELECT
    COALESCE(CAST(Sale_Year AS CHAR), 'GRAND TOTAL')    AS Year,
    COALESCE(Sale_Month, 'YEAR TOTAL')                  AS Month,
    COUNT(*)                                             AS Trading_Days,
    ROUND(SUM(Total_Rev), 2)                            AS Total_Revenue,
    FORMAT(SUM(Total_Units), 0)                         AS Total_Units
FROM Sales_Data
GROUP BY Sale_Year, Sale_Month
    WITH ROLLUP
ORDER BY Sale_Year, MIN(Month_No);