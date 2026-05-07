Create database if not exists Sales_Analytics;
Use Sales_Analytics;
Create Table if not exists Sales_Data(
Sl_no Int Not Null,
Sale_date Date Not Null,
Sale_Year smallint Not Null,
Sale_Month Varchar(3) Not Null,
Month_No TinyInt Not Null,
-- Product1
qty_P1 Int Not Null Default 0,
rev_P1 Decimal(12,2) Not Null default 0.00,
Price_P1 Decimal(8,4) not null default 0.00,
-- Product2
qty_P2 Int Not Null Default 0,
rev_P2 Decimal(12,2) Not Null default 0.00,
Price_P2 Decimal(8,4) not null default 0.00,
-- Product3
qty_P3 Int Not Null Default 0,
rev_P3 Decimal(12,2) Not Null default 0.00,
Price_P3 Decimal(8,4) not null default 0.00,
-- Product4
qty_P4 Int Not Null Default 0,
rev_P4 Decimal(12,2) Not Null default 0.00,
Price_P4 Decimal(8,4) not null default 0.00,
-- Totals
Total_Units Int Not null default 0,
Total_Rev Decimal(12,2) not null Default 0.00,
-- Calculated Columns
Quarter Varchar(2) Not null,
Day_Name varchar(10) Not Null,
Rev_Per_Unit Decimal(10,4) Not Null Default 0.00,
top_product    VARCHAR(15)    NOT NULL,
rev_category   VARCHAR(10)    NOT NULL,
yoy_flag       VARCHAR(15)    NOT NULL,
-- primary key & Indexes
 PRIMARY KEY (sl_no),
INDEX idx_date       (sale_date),
INDEX idx_year       (sale_year),
INDEX idx_yr_month   (sale_year, month_no),
INDEX idx_revenue    (total_rev),
INDEX idx_category   (rev_category),
INDEX idx_quarter    (quarter)) 
ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COMMENT='Daily multi-product sales data 2010-2023 | Kashish Kedia';
  Show tABLES;
  describe sales_data;
  show create table sales_data;
-- DATA CHECK
-- How many Rows Imported?
select count(*) as total_rows from sales_data;
-- Date Range Correct?
select min(sale_date) as earliest_date,max(sale_date) as latest_data from sales_data;
-- Total revenue matches excel?
select round(sum(Total_rev),2) as Total_Revenue from sales_data;
-- SAMPLE 1ST 5 ROWS
Select * from sales_data limit 5;
-- SAMPLE LAST 5 ROWS
select * from sales_data order by sl_no desc limit 5;
-- ================================================
-- Q1: DATASET OVERVIEW
-- Shows key stats about entire dataset at once
-- ================================================
select
count(*) as Total_records,
min(sale_date) as earliest_date,
max(sale_date) as latest_date,
count(distinct sale_year) as years_covered,
round(sum(total_rev),2) as grand_total_revenue,
format(sum(total_units),0) as grand_total_units,
round(avg(total_rev),2) as Average_daily_revenue,
round(max(total_rev),2) as best_day_revenue,
round(min(total_rev),2) as worst_day_revenue
from sales_data;
-- ================================================
-- Q2: YEARLY REVENUE PERFORMANCE
-- One row per year showing key metrics
-- ================================================
select
sale_year as year,
count(*) as trading_days,
format(sum(total_units),0) as total_units_sold,
round(sum(Total_rev),2) as Total_revenue,
round(avg(Total_rev),2) as avg_daily_revenue,
round(max(total_rev),2) as Best_day,
round(min(Total_rev),2) as worst_day,
round(sum(total_rev)/count(*),2) as revenue_per_day
from sales_data
group by sale_year
order by sale_year;
-- ================================================
-- Q3: MONTHLY REVENUE PATTERN (All Years Combined)
-- Reveals seasonal trends across entire dataset
-- ================================================
select
month_no as month_number,
sale_month as month_name,
count(*) as total_days,
round(sum(total_rev),2) as total_revenue,
round(avg(total_rev),2) as avg_daily_revenue,
round(sum(total_rev)/sum(sum(total_rev)) over()*100,2) as revenue_share_pct
from sales_data
group by month_no,sale_month
order by month_no;
-- ================================================
-- Q4: PRODUCT PERFORMANCE BREAKDOWN
-- Compare all 4 products side by side
-- ================================================
SELECT
    'Product 1'                             AS Product,
    FORMAT(SUM(qty_P1), 0)                 AS Total_Units,
    ROUND(SUM(rev_P1), 2)                  AS Total_Revenue,
    ROUND(AVG(Price_P1), 4)               AS Avg_Price,
    ROUND(SUM(rev_P1) /(SELECT SUM(Total_Rev) FROM Sales_Data) * 100, 2)       AS Revenue_Share_Pct
from sales_data
UNION ALL
SELECT
    'Product 2',
    FORMAT(SUM(qty_P2), 0),
    ROUND(SUM(rev_P2), 2),
    ROUND(AVG(Price_P2), 4),
    ROUND(SUM(rev_P2) /(SELECT SUM(Total_Rev) FROM Sales_Data) * 100, 2)
FROM Sales_Data

UNION ALL

SELECT
    'Product 3',
    FORMAT(SUM(qty_P3), 0),
    ROUND(SUM(rev_P3), 2),
    ROUND(AVG(Price_P3), 4),
    ROUND(SUM(rev_P3) /(SELECT SUM(Total_Rev)FROM Sales_Data) * 100, 2)
FROM Sales_Data
UNION ALL
SELECT
    'Product 4',
    FORMAT(SUM(qty_P4), 0),
    ROUND(SUM(rev_P4), 2),
    ROUND(AVG(Price_P4), 4),
    ROUND(SUM(rev_P4) /(SELECT SUM(Total_Rev)FROM Sales_Data) * 100, 2)
FROM Sales_Data

ORDER BY Total_Revenue DESC;
-- ================================================
-- Q5: TOP 10 BEST REVENUE DAYS
-- Find the single best performing days
-- ================================================
SELECT
    Sl_no                                   AS Record_No,
    Sale_date                               AS Date,
    Sale_Year                               AS Year,
    Sale_Month                              AS Month,
    Day_Name                                AS Day,
    ROUND(Total_Rev, 2)                    AS Daily_Revenue,
    FORMAT(Total_Units, 0)                  AS Units_Sold,
    ROUND(Rev_Per_Unit, 4)                 AS Revenue_Per_Unit,
    Top_Product                             AS Best_Product,
    Rev_Category                            AS Category
FROM Sales_Data
ORDER BY Total_Rev DESC
LIMIT 10;
-- ================================================
-- Q6: BOTTOM 10 WORST REVENUE DAYS
-- Identify underperforming days
-- ================================================
SELECT
    Sale_date                               AS Date,
    Sale_Year                               AS Year,
    Sale_Month                              AS Month,
    Day_Name                                AS Day_Of_Week,
    ROUND(Total_Rev, 2)                    AS Daily_Revenue,
    FORMAT(Total_Units, 0)                  AS Units_Sold,
    Top_Product                             AS Best_Product,
    Rev_Category                            AS Category
FROM Sales_Data
ORDER BY Total_Rev ASC
LIMIT 10;
-- ================================================
-- Q7: REVENUE CATEGORY DISTRIBUTION
-- Uses your calculated Rev_Category column
-- ================================================
SELECT
    Rev_Category                            AS Category,
    COUNT(*)                                AS Total_Days,
    ROUND(COUNT(*) / 4600 * 100, 1)       AS Pct_Of_Days,
    ROUND(SUM(Total_Rev), 2)               AS Total_Revenue,
    ROUND(AVG(Total_Rev), 2)               AS Avg_Revenue,
    ROUND(MIN(Total_Rev), 2)               AS Min_Revenue,
    ROUND(MAX(Total_Rev), 2)               AS Max_Revenue
FROM Sales_Data
GROUP BY Rev_Category
ORDER BY
    CASE Rev_Category
        WHEN 'High'   THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'Low'    THEN 3
    END;
-- ================================================
-- Q8: DAY OF WEEK REVENUE PATTERN
-- Are weekends better or worse than weekdays?
-- ================================================
SELECT
    Day_Name                                AS Day_Of_Week,
    COUNT(*)                                AS Total_Days,
    ROUND(AVG(Total_Rev), 2)               AS Avg_Daily_Revenue,
    ROUND(SUM(Total_Rev), 2)               AS Total_Revenue,
    ROUND(MAX(Total_Rev), 2)               AS Best_Day_Revenue,
    ROUND(MIN(Total_Rev), 2)               AS Worst_Day_Revenue,
    CASE
        WHEN Day_Name IN ('Saturday','Sunday')
        THEN 'Weekend'
        ELSE 'Weekday'
    END                                     AS Day_Type
FROM Sales_Data
GROUP BY Day_Name
ORDER BY Avg_Daily_Revenue DESC;
-- ================================================
-- Q9: QUARTERLY REVENUE SUMMARY
-- Quarter1 through Quarter4 performance across all years
-- ================================================
select quarter as quarter,
count(*) as total_days,
round(sum(total_rev),2) as total_revenue,
round(avg(total_rev),2) as average_daily_revenue,
round(sum(total_rev)/sum(sum(total_rev)) over()*100,2) as revenue_per_pct,
format(sum(total_units),0) as total_units
from sales_data
group by quarter
order by quarter;
-- ================================================
-- Q10: FILTERED ANALYSIS USING WHERE
-- WHERE filters individual rows BEFORE grouping
-- ================================================
select sale_year as year,
month_no as months,
sale_month as month,
count(*) as high_rev_days,
round(sum(total_rev),2) as total_revenue,
round(avg(total_rev),2) as average_revenue
from sales_Data
where 
rev_category="High"     -- only high revenue days
and sale_year between 2018 and 2020 -- only these 3 years
group by sale_year,month_no,sale_month
order by sale_year,month_no;
-- ================================================
-- Q11: HAVING CLAUSE EXAMPLE
-- HAVING filters GROUPS after GROUP BY
-- ================================================
select
sale_year as year,
round(sum(total_rev),2) as total_revenue,
count(*) as trading_days
from sales_Data
group by sale_year
having sum(total_rev)>18000000
order by total_revenue desc;
-- ================================================
-- Q12: YEAR + MONTH REVENUE DETAIL
-- Most granular time-based breakdown
-- ================================================
select sale_year as year,
month_no as month_no,
sale_month as month,
count(*) as trading_days,
round(sum(total_rev),2) as total_revenue,
round(avg(total_rev),2) as avg_daily_Revenue,
format(sum(total_units),0) as total_units
from sales_data
group by sale_year,month_no,sale_month
order by sale_year,month_no;
-- ================================================
-- Q13: GROWTH vs DECLINE YEAR SUMMARY
-- Uses your YoY_Flag calculated column
-- ================================================
select
yoy_flag as year_type,
count(distinct Sale_year) as no_of_years,
group_concat(distinct sale_year order by sale_year separator",") as which_years,
round(avg(total_rev),2) as avg_daily_revenue
from sales_Data
where yoy_flag !=''
group by yoy_flag
order by yoy_flag desc;
-- ================================================
-- Q14: DATA QUALITY CROSS-CHECK
-- Verify MySQL matches your Excel dashboard
-- ================================================
SELECT
    'Total Records'                         AS Metric,
    CAST(COUNT(*) AS CHAR)                 AS Value,
    '4600'                                  AS Expected,
    CASE WHEN COUNT(*) = 4600
         THEN 'MATCH'
         ELSE 'MISMATCH'
    END                                     AS Status
FROM Sales_Data

UNION ALL

SELECT
    'Total Revenue',
    CAST(ROUND(SUM(Total_Rev), 0) AS CHAR),
    '237510477',
    CASE WHEN ROUND(SUM(Total_Rev), 0) = 237510477
         THEN 'MATCH'
         ELSE 'MISMATCH'
    END
FROM Sales_Data

UNION ALL

SELECT
    'First Date',
    CAST(MIN(Sale_date) AS CHAR),
    '2010-06-13',
    CASE WHEN MIN(Sale_date) = '2010-06-13'
         THEN 'MATCH'
         ELSE 'MISMATCH'
    END
FROM Sales_Data

UNION ALL

SELECT
    'Last Date',
    CAST(MAX(Sale_date) AS CHAR),
    '2023-02-03',
    CASE WHEN MAX(Sale_date) = '2023-02-03'
         THEN 'MATCH'
         ELSE 'MISMATCH'
    END
FROM Sales_Data;