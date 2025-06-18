
 
 -- Can we identify seasonal trends in sales?--
-- Query Overview: Identifying Seasonal Sales Trends
/* This SQL query analyzes monthly revenue trends across product categories and years to uncover potential seasonal sales patterns.
It calculates the total monthly revenue and compares it to the same month in the previous year, providing both:
📊 Total Revenue per category, month, and year
📈 Year-over-Year Growth (%) for the same month and category

This helps identify:
High or low performing months per category (e.g. seasonal peaks)
Year-over-year improvements or declines in sales performance
Possible seasonal sales cycles (e.g. toys selling more in December) */


 
 

SELECT 
	Year(s.Date) as Sale_Year,
    p.Product_Category,
	MONTH(s.Date) AS Sale_Month,
	round(SUM(s.Units * p.Product_Price), 2) AS Revenue
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
GROUP BY Year(s.Date), MONTH(s.Date), p.Product_Category
ORDER BY p.Product_Category, Sale_Year,  Sale_Month ;



SELECT 
    Year(s.Date) AS Sale_Year,
    p.Product_Category,
    MONTH(s.Date) AS Sale_Month,
    ROUND(SUM(s.Units * p.Product_Price), 2) AS Revenue,
    LAG(ROUND(SUM(s.Units * p.Product_Price), 2)) OVER (
        PARTITION BY p.Product_Category, MONTH(s.Date)
        ORDER BY Year(s.Date)
    ) AS Last_Year_Revenue,
   
   CASE 
        WHEN LAG(SUM(s.Units * p.Product_Price)) OVER (
            PARTITION BY p.Product_Category, MONTH(s.Date)
            ORDER BY Year(s.Date)
        ) IS NOT NULL 
        THEN ROUND(
            (SUM(s.Units * p.Product_Price) - LAG(SUM(s.Units * p.Product_Price)) OVER (
                PARTITION BY p.Product_Category, MONTH(s.Date)
                ORDER BY Year(s.Date)
            )) / LAG(SUM(s.Units * p.Product_Price)) OVER (
                PARTITION BY p.Product_Category, MONTH(s.Date)
                ORDER BY Year(s.Date)
            ) * 100, 2)
        ELSE NULL
    END AS Growth_Pct
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
GROUP BY Year(s.Date), MONTH(s.Date), p.Product_Category
ORDER BY p.Product_Category, Sale_Year, Sale_Month;
 

 
 
-- TOP10 DAYS SALES

			SELECT 
			  date_format(Date, '%Y %M %d'), 
			  CONCAT('MXN$ ', FORMAT(SUM(Units * Product_Price), 2)) AS total
			FROM Sales s
			JOIN Products p ON s.Product_ID = p.Product_ID
			GROUP BY Date
			ORDER BY SUM(Units * Product_Price) DESC
			LIMIT 10;

			/* Days Description
			 30 April 2023 (Sunday) – Día del Niño (Children’s Day)
			A widely celebrated day in Mexico where children receive gifts and enjoy special events.

			Retailers often experience a surge in toy sales leading up to and on this day.

			 2. 10 March 2023 (Friday)
			While not a national holiday, this date coincided with a major lucha libre (wrestling) event, which are culturally significant in Mexico.

			Such events can boost related merchandise sales, including action figures and toys.

			 3. 24 December 2022 (Saturday) – Christmas Eve
			A peak shopping day in Mexico as families prepare for Christmas celebrations.

			Last-minute gift purchases, especially toys, are common.

			4. 6 January 2023 (Friday) – Día de Reyes (Epiphany)
			Traditionally, Mexican children receive gifts on this day, commemorating the visit of the Three Wise Men.

			Toy sales often spike in the days leading up to this celebration.

			5. 30 April 2022 (Saturday) – Día del Niño (Children’s Day)
			As with 2023, this day is dedicated to celebrating children, leading to increased toy sales.

			6. 29 April 2023 (Saturday)
			The day before Children's Day in 2023, likely benefiting from early celebrations and gift purchases.

			7. 30 March 2023 (Thursday)
			While not a public holiday, this date falls close to the start of Semana Santa (Holy Week), a period when many families travel and shop for the holidays.

			8. 18 March 2023 (Saturday) – Oil Expropriation Day
			A national observance commemorating the 1938 expropriation of oil reserves.

			While not a major shopping holiday, it may coincide with local events or parades that boost sales.
			sites.google.com

			9. 8 April 2023 (Saturday) – Holy Saturday
			Part of Semana Santa, a significant religious period in Mexico.

			Many families are on vacation, leading to increased spending in various sectors, including retail.

			10. 3 February 2023 (Friday)
			While not a national holiday, this date is close to Candlemas (2 February), a traditional celebration involving family gatherings, which might influence shopping behavior.

			*/



-- TOP 3 PRODUCTS SOLD on the top 10 days

			WITH TopDates AS (
			  SELECT 
				s.Date,
				SUM(s.Units * p.Product_Price) AS total_revenue
			  FROM Sales s
			  JOIN Products p ON s.Product_ID = p.Product_ID
			  GROUP BY s.Date
			  ORDER BY total_revenue DESC
			  LIMIT 10
			),
			ProductSales AS (
			  SELECT
				s.Date,
				p.Product_Name,
				SUM(s.Units * p.Product_Price) AS revenue,
                RANK() OVER (PARTITION BY Date ORDER BY SUM(s.Units * p.Product_Price) DESC) AS ranking
			  FROM Sales s
			  JOIN Products p ON s.Product_ID = p.Product_ID
			  WHERE s.Date IN (SELECT Date FROM TopDates)
			  GROUP BY s.Date, p.Product_Name
			),
			
			finalresult as (
			SELECT date_format(Date, '%Y %M %d'), Product_Name, revenue as Revenue
			FROM ProductSales
			WHERE ranking <= 3
			ORDER BY Date, revenue asc)
				
             -- SELECT * FROM  ProductSales;
			   -- SELECT * FROM finalresult;
			--  SELECT distinct Product_Name from finalresult;
			   select Product_Name, count(*) as Total_Days, format( sum(revenue), 2 ) as Revenue from finalresult  GROUP by 1;


 
 
 
 
 
 -- Which product categories drive the biggest profits?
 
  /*Toys generate the highest total profit:

MXN$ 1,079,527 — they also rank #1 in revenue and #2 in quantity sold, showing both high volume and financial impact. But in terms of profit margin it is ranked last with 21%
*/
 
  With maintable as (
SELECT 
	p.Product_Category,
    
    -- Raw revenue & profit for sorting/charting
    SUM(s.Units * p.Product_Price) AS Revenue_Value,
    SUM(s.Units * p.Product_Price) - SUM(s.Units * p.Product_Cost) AS Profit_Value,
    SUM(s.Units ) AS Qt_value,
	count(*) as TotalOrders,
    
    -- Pre-formatted fields for visual display (if needed)
    CONCAT('MXN$ ', FORMAT(SUM(s.Units * p.Product_Price), 2)) AS Revenue,
    CONCAT('MXN$ ', FORMAT(SUM(s.Units * p.Product_Price) - SUM(s.Units * p.Product_Cost), 2)) AS Profit,
    FORMAT(SUM(s.Units), 2) AS QT_Sold,
    ROUND( (SUM(s.Units * p.Product_Price) - SUM(s.Units * p.Product_Cost)) / NULLIF(SUM(s.Units * p.Product_Price), 0), 2 )  AS Profit_Margin,

    -- Rankings
    DENSE_RANK() OVER (ORDER BY SUM(s.Units * p.Product_Price) DESC) AS Rank_Revenue,
    DENSE_RANK() OVER (ORDER BY (SUM(s.Units * p.Product_Price) - SUM(s.Units * p.Product_Cost)) DESC) AS Rank_Profit,
    DENSE_RANK() OVER (ORDER BY SUM(s.Units) DESC) AS Rank_Qt
    

FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
GROUP BY p.Product_Category),
-- ORDER BY Revenue_Value DESC),

maintableyear as (
SELECT 
	p.Product_Category,
    year(s.date) as Years,
    
    -- Raw revenue & profit for sorting/charting
    SUM(s.Units * p.Product_Price) AS Revenue_Value,
    SUM(s.Units * p.Product_Price) - SUM(s.Units * p.Product_Cost) AS Profit_Value,
    SUM(s.Units ) AS QT_Sold,
    count(*) as TotalOrders,

    -- Pre-formatted fields for visual display (if needed)
    CONCAT('MXN$ ', FORMAT(SUM(s.Units * p.Product_Price), 2)) AS Revenue,
    CONCAT('MXN$ ', FORMAT(SUM(s.Units * p.Product_Price) - SUM(s.Units * p.Product_Cost), 2)) AS Profit,
    ROUND( (SUM(s.Units * p.Product_Price) - SUM(s.Units * p.Product_Cost)) / NULLIF(SUM(s.Units * p.Product_Price), 0), 2 )  AS Profit_Margin,

    -- Rankings
    DENSE_RANK() OVER (partition by  year(s.date) ORDER BY SUM(s.Units * p.Product_Price) DESC) AS Rank_Revenue,
    DENSE_RANK() OVER (partition by year(s.date) ORDER BY (SUM(s.Units * p.Product_Price) - SUM(s.Units * p.Product_Cost)) DESC) AS Rank_Profit,
    DENSE_RANK() OVER (partition by  year(s.date) ORDER BY SUM(s.Units) DESC) AS Rank_Qt
    

FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
GROUP BY Years, p.Product_Category )

 SELECT Product_Category, TotalOrders, QT_Sold, Revenue, Profit, Profit_Margin, Rank_Revenue, Rank_Profit, Rank_Qt FROM  maintable;

 /*  SELECT Years, Product_Category, QT_Sold, Revenue, Profit, Profit_Margin, Rank_Revenue, Rank_Profit, Rank_Qt
 FROM  maintableyear
 ORDER BY Years desc , Revenue_Value DESC;*/
 
	
 
 
 -- breakdown of Toys sales volume by product for each year
 /*
 Annual Breakdown of Toy Sales by Product
This SQL query provides a year-by-year analysis of toy sales, including:
 Units sold, 💰 Total revenue, and 🧾 Total profit for each toy
 Profit margin (Profit ÷ Revenue)
 Ranking of toys by revenue and profit within each year

This breakdown helps answer:
Which toys sold the most each year?
Which were the most profitable?
Are certain toys consistently top performers?
It’s a great way to track product performance over time and inform sales or inventory decisions.*/
 
 
 SELECT * 
 FROM PRODUCTs
 where Product_Category = 'Toys';
 
WITH ToySales AS (
    SELECT
        YEAR(s.Date) AS Sales_Year,
        p.Product_Name,
        SUM(s.Units) AS Units_Sold,
        SUM(s.Units * p.Product_Price) AS Revenue,
        SUM(s.Units * (p.Product_Price - p.Product_Cost)) AS Profit
    FROM Sales s
    JOIN Products p ON s.Product_ID = p.Product_ID
    WHERE p.Product_Category = 'Toys'
    GROUP BY Sales_Year, p.Product_Name
)

SELECT
    Sales_Year,
    Product_Name,
    Units_Sold,
    ROUND(Revenue, 2) AS Revenue,
    ROUND(Profit, 2) AS Profit,
    ROUND(Profit / NULLIF(Revenue, 0), 2) AS Profit_Margin,
    DENSE_RANK() OVER (PARTITION BY Sales_Year ORDER BY Revenue DESC) AS Rank_Revenue,
    DENSE_RANK() OVER (PARTITION BY Sales_Year ORDER BY Profit DESC) AS Rank_Profit
FROM ToySales
-- ORDER BY Product_Name, Sales_Year, Rank_Revenue
  ORDER BY  Sales_Year, Rank_Revenue, Product_Name  ;

 
 
 
 
 
 
 
 
 
-- Pricing strategy issue
		/*
		Spotting Pricing Strategy Issues by Product
		This query analyzes product-level profitability to uncover potential pricing or cost inefficiencies.

		It calculates:
		Revenue, Profit, and Profit Margin per product
		📊 Rankings by revenue, profit, and quantity sold
		✅ Pre-formatted values for clearer display (e.g., "MXN$ 1,234.56")

		💡 Use cases:
		🔍 Identify products with high revenue but poor profit → Possible cost/pricing issue
		🛑 Spot products with very low profit margins
		🧠 Detect underperforming opportunities: high profit margins but low revenue → Maybe under-marketed
		This is a great diagnostic tool to fine-tune your pricing strategy.
		*/

 
 With maintable as (
SELECT 
	p.Product_Category,
    p.Product_name,
    
    -- Raw revenue & profit for sorting
    SUM(s.Units * p.Product_Price) AS Revenue_Value,
    SUM(s.Units * p.Product_Price) - SUM(s.Units * p.Product_Cost) AS Profit_Value,
    SUM(s.Units ) AS Qt_value,

    -- Pre-formatted fields for visual display
    CONCAT('MXN$ ', FORMAT(SUM(s.Units * p.Product_Price), 2)) AS Revenue,
    CONCAT('MXN$ ', FORMAT(SUM(s.Units * p.Product_Price) - SUM(s.Units * p.Product_Cost), 2)) AS Profit,
    FORMAT(SUM(s.Units * p.Product_Price), 2) AS QT_Sold,
    ROUND( (SUM(s.Units * p.Product_Price) - SUM(s.Units * p.Product_Cost)) / NULLIF(SUM(s.Units * p.Product_Price), 0), 2 )  AS Profit_Margin,

    -- Rankings
    DENSE_RANK() OVER (ORDER BY SUM(s.Units * p.Product_Price) DESC) AS Rank_Revenue,
    DENSE_RANK() OVER (ORDER BY (SUM(s.Units * p.Product_Price) - SUM(s.Units * p.Product_Cost)) DESC) AS Rank_Profit,
    DENSE_RANK() OVER (ORDER BY SUM(s.Units) DESC) AS Rank_Qt
    

FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
GROUP BY p.Product_Category, p.Product_name
ORDER BY Revenue_Value DESC)

  -- SELECT Product_Category, Product_name, Revenue, Profit, Profit_Margin, Rank_Revenue, Rank_Profit, Rank_Qt FROM  maintable;
 -- SELECT Product_Category, Product_name, Revenue, Profit, Profit_Margin, Rank_Revenue, Rank_Profit, Rank_Qt FROM  maintable where Rank_Revenue < 10 and Rank_Profit > 10; -- That mismatch screams: "Pricing strategy issue" or "Cost too high".
 -- SELECT Product_Category, Product_name, Revenue, Profit, Profit_Margin, Rank_Revenue, Rank_Profit, Rank_Qt FROM  maintable where Profit_Margin < 0.2;
 -- SELECT Product_Category, Product_name, Revenue, Profit, Profit_Margin, Rank_Revenue, Rank_Profit, Rank_Qt FROM  maintable where Profit_Margin > 0.4 and Rank_Revenue > 20; 










-- Are certain categories stronger in Downtown vs Residential vs Airport stores?
/*
Comparing Product Category Performance Across Store Types
➡️ Are certain product categories stronger in Downtown vs Residential vs Airport stores?

It analyzes and ranks each product category's performance by:
 Total Revenue
 Total Profit
 Profit Margin
 Units Sold

For each store location type, it returns:
The performance metrics (Revenue, Profit, etc.)
 Rankings within each location by Revenue, Profit, and Profit Margin

This allows you to spot:
 Top-performing categories by store type
 Categories with low profitability in certain locations
 Opportunities to optimize product mix and pricing per location
*/

SELECT 
    st.Store_Location,
    p.Product_Category,
    ROUND( SUM(s.Units * p.Product_Price), 2 ) AS Revenue,
    SUM(s.Units * p.Product_Price - s.Units * p.Product_Cost) AS Profit,
    SUM(s.Units) AS Units_Sold,
    ROUND(SUM(s.Units * p.Product_Price - s.Units * p.Product_Cost) / NULLIF(SUM(s.Units * p.Product_Price), 0), 2) AS Profit_Margin
FROM	Sales s
JOIN	Products p ON s.Product_ID = p.Product_ID
JOIN	Stores st ON s.Store_ID = st.Store_ID
GROUP BY st.Store_Location, p.Product_Category
ORDER BY st.Store_Location, Revenue DESC;



WITH RankedMetrics AS (
  SELECT 
      st.Store_Location,
      p.Product_Category,
      ROUND(SUM(s.Units * p.Product_Price), 2) AS Revenue,
      SUM(s.Units * p.Product_Price - s.Units * p.Product_Cost) AS Profit,
      SUM(s.Units) AS Units_Sold,
      ROUND(SUM(s.Units * p.Product_Price - s.Units * p.Product_Cost) / NULLIF(SUM(s.Units * p.Product_Price), 0), 2) AS Profit_Margin
  FROM Sales s
  JOIN Products p ON s.Product_ID = p.Product_ID
  JOIN Stores st ON s.Store_ID = st.Store_ID
  GROUP BY st.Store_Location, p.Product_Category
)

SELECT 
    *,
    RANK() OVER (PARTITION BY Store_Location ORDER BY Revenue DESC) AS Rank_Revenue,
    RANK() OVER (PARTITION BY Store_Location ORDER BY Profit DESC) AS Rank_Profit,
    RANK() OVER (PARTITION BY Store_Location ORDER BY Profit_Margin DESC) AS Rank_Margin
FROM	RankedMetrics
-- WHERE	Product_Category = 'Electronics'
ORDER BY Store_Location, Rank_Revenue;









-- Zoom In Sports & Outdoors - considering taking out from airport? and check others also


With 
	store_counts as (
			SELECT Store_Location AS Location,
					COUNT(*) AS total_stores
			FROM maven_toys.stores
			group by 1),

FinalTable as (
SELECT 
    p.Product_Name,
    p.Product_Category,
    st.Store_Location,
    SUM(s.Units) AS Units_Sold,
    DATE_FORMAT(MIN(s.date), '%Y, %M %d') AS First_SellingDate,
    DATE_FORMAT(max(s.date), '%Y, %M %d') as last_sellingDate,
    datediff ( max(s.date), min(s.date) ) as DaysSelling,
    sc.total_stores as N_Stores_sold,
    round ( (SUM(s.Units) / datediff ( max(s.date), min(s.date) ) ) / sc.total_stores , 2) as UnitsPerDay_PerStore,
    round(SUM(s.Units * p.Product_Price), 2 ) AS Revenue,
   round( SUM(s.Units * p.Product_Price - s.Units * p.Product_Cost), 2) AS Profit
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
JOIN Stores st ON s.Store_ID = st.Store_ID
JOIN store_counts sc on sc.Location = st.Store_Location
WHERE p.Product_Category = 'Sports & Outdoors'
GROUP BY p.Product_Name, st.Store_Location
ORDER BY Store_Location, Revenue DESC)

SELECT * FROM finaltable;
--  WHERE UnitsPerDay_PerStore >= 1.2; -- and Profit < 10000;











-- STOCK Are sales being lost due to out-of-stock items?

-- OBJECTIVE:
-- This query investigates whether sales are potentially being lost due to products being out of stock or running low.
-- The analysis is done at the Store-Product level. It involves two main steps:
-- 1. Aggregating historical sales data to calculate average units sold per day (Units_Per_Day).
-- 2. Combining this with current inventory levels to estimate how many days of stock remain (Days_Left).
-- The final output highlights products with 7 or fewer days of stock left — or that are completely out of stock.

-- STEP 1: Calculate historical sales performance per store and product

-- CTE to get the last date in the sales table (same for all products)
WITH MaxSalesDate AS (
  SELECT MAX(Date) AS Last_Sale_Date
  FROM maven_toys.sales
),

SalesStats AS (
SELECT 
    s.Store_ID,
    s.Product_ID,
    MIN(s.Date) AS First_Sale_Date,                                      -- When sales for this product started
    msd.Last_Sale_Date,                                                  -- When the dataset ends
    DATEDIFF(msd.Last_Sale_Date, MIN(s.Date)) + 1 AS Total_Days_Tracked, -- Total time window (include both endpoints)
    SUM(s.Units) AS Units_Sold,                                          -- Total units sold
    ROUND(SUM(s.Units) / NULLIF(DATEDIFF(msd.Last_Sale_Date, MIN(s.Date)) + 1, 0), 2) AS Units_Per_Day -- Sales velocity
FROM maven_toys.sales s
CROSS JOIN MaxSalesDate msd  -- Apply same max date to every row
GROUP BY s.Store_ID, s.Product_ID, msd.Last_Sale_Date
),

-- STEP 2: Estimate how long current stock will last based on historical daily sales
StockAnalysis AS (
    SELECT 
        ss.Store_ID,
        ss.Product_ID,
        ss.Total_Days_Tracked,
        ss.Units_Sold,
        ss.Units_Per_Day,
        i.Stock_On_Hand,
        ROUND(i.Stock_On_Hand / NULLIF(ss.Units_Per_Day, 0), 1) AS Days_Left -- Remaining days before stock runs out
    FROM SalesStats ss
    JOIN maven_toys.inventory i 
        ON ss.Store_ID = i.Store_ID AND ss.Product_ID = i.Product_ID
)

 Select * From SalesStats;

-- FINAL OUTPUT: Focus only on products that are at risk of being out of stock soon
SELECT 
    sa.*,                             -- Sales and stock metrics
    p.Product_Category,
    p.Product_Name,
    st.Store_Name
FROM StockAnalysis sa
JOIN maven_toys.products p ON sa.Product_ID = p.Product_ID
JOIN maven_toys.stores st ON sa.Store_ID = st.Store_ID
WHERE sa.Days_Left <= 7              -- Flag low stock (<= 1 week left based on sales rate)
   OR sa.Stock_On_Hand = 0           -- Flag completely out-of-stock items
ORDER BY sa.Days_Left ASC;           -- Prioritize the most urgent stockouts







-- OBJECTIVE:
-- This script combines *product performance* with *stock availability* at the store level to evaluate risk of sales loss.
-- It does so by ranking products by revenue, profit, and quantity sold per store and matching this with current stock levels.
-- A final "Stock_Status" flag helps identify urgent stock issues, especially for top-performing products.

-- STEP 1: Compute average units sold per day (sales velocity) for each product in each store
WITH MaxSalesDate AS (
  SELECT MAX(Date) AS Last_Sale_Date
  FROM maven_toys.sales
),

SalesStats AS (
SELECT 
    s.Store_ID,
    s.Product_ID,
    MIN(s.Date) AS First_Sale_Date,                                      -- When sales for this product started
    msd.Last_Sale_Date,                                                  -- When the dataset ends
    DATEDIFF(msd.Last_Sale_Date, MIN(s.Date)) + 1 AS Total_Days_Tracked, -- Total time window (include both endpoints)
    SUM(s.Units) AS Units_Sold,                                          -- Total units sold
    ROUND(SUM(s.Units) / NULLIF(DATEDIFF(msd.Last_Sale_Date, MIN(s.Date)) + 1, 0), 2) AS Units_Per_Day -- Sales velocity
FROM maven_toys.sales s
CROSS JOIN MaxSalesDate msd  -- Apply same max date to every row
GROUP BY s.Store_ID, s.Product_ID, msd.Last_Sale_Date
),

-- STEP 2: Estimate how long current stock will last based on historical daily sales
StockAnalysis AS (
    SELECT 
        ss.Store_ID,
        ss.Product_ID,
        ss.Total_Days_Tracked,
        ss.Units_Sold,
        ss.Units_Per_Day,
        i.Stock_On_Hand,
        ROUND(i.Stock_On_Hand / NULLIF(ss.Units_Per_Day, 0), 1) AS Days_Left -- Remaining days before stock runs out
    FROM SalesStats ss
    JOIN maven_toys.inventory i 
        ON ss.Store_ID = i.Store_ID AND ss.Product_ID = i.Product_ID
),

-- STEP 3: Create a ranking of products per store based on sales performance
maintable AS (
    SELECT 
        p.Product_Category,
        p.Product_name,
        p.Product_id,
        s.Store_ID,
        
        -- Raw metrics
        SUM(s.Units * p.Product_Price) AS Revenue_Value,
        SUM(s.Units * p.Product_Price - s.Units * p.Product_Cost) AS Profit_Value,
        SUM(s.Units ) AS Qt_value,

        -- Formatted fields for visuals (Power BI, dashboards, etc.)
        CONCAT('MXN$ ', FORMAT(SUM(s.Units * p.Product_Price), 2)) AS Revenue,
        CONCAT('MXN$ ', FORMAT(SUM(s.Units * p.Product_Price - s.Units * p.Product_Cost), 2)) AS Profit,
        ROUND((SUM(s.Units * p.Product_Price - s.Units * p.Product_Cost)) / NULLIF(SUM(s.Units * p.Product_Price), 0), 2) AS Profit_Margin,

        -- Product rankings per store (based on Revenue, Profit, and Quantity sold)
        DENSE_RANK() OVER (PARTITION BY s.Store_ID ORDER BY SUM(s.Units * p.Product_Price) DESC) AS Rank_Revenue,
        DENSE_RANK() OVER (PARTITION BY s.Store_ID ORDER BY (SUM(s.Units * p.Product_Price - s.Units * p.Product_Cost)) DESC) AS Rank_Profit,
        DENSE_RANK() OVER (PARTITION BY s.Store_ID ORDER BY SUM(s.Units) DESC) AS Rank_Qt

    FROM Sales s
    JOIN Products p ON s.Product_ID = p.Product_ID
    GROUP BY s.Store_ID, p.Product_Category, p.Product_name, p.Product_id
)

-- STEP 4: Combine performance and stock data, and define a decision layer for stock urgency
SELECT 
    m.Store_ID,
    st.Store_City,
    st.store_name,
    m.Product_ID,
    m.Product_Category,
    m.Product_Name,
    m.Revenue,
    m.Profit,
    m.Profit_Margin,
    m.Rank_Revenue,
    m.Rank_Profit,
    m.Rank_Qt,
    sa.Stock_On_Hand,
    sa.Units_Per_Day,
    sa.Days_Left,

    -- Decision Layer: Label each product with a stock status based on urgency and importance
    CASE 
        WHEN sa.Stock_On_Hand = 0 THEN 'Out of Stock'
        WHEN sa.Days_Left < 2 AND m.Rank_Revenue <= 5 THEN 'Critical'
        WHEN sa.Days_Left < 2 THEN 'Urgent'
        WHEN sa.Days_Left BETWEEN 2 AND 5 AND m.Rank_Revenue <= 5 THEN 'At Risk'
        WHEN sa.Days_Left BETWEEN 2 AND 5 THEN 'Monitor'
        ELSE 'Stable'
    END AS Stock_Status

FROM maintable m
JOIN StockAnalysis sa 
    ON m.Store_ID = sa.Store_ID AND m.Product_ID = sa.Product_ID
LEFT JOIN stores st ON m.Store_ID = st.Store_ID

-- Uncomment and tweak the WHERE clause depending on the focus:
 WHERE (sa.Days_Left <= 2 OR sa.Stock_On_Hand = 0) AND Rank_Revenue <= 5   -- Focus on urgent + high-sellers
-- WHERE sa.Stock_On_Hand = 0 AND Rank_Revenue <= 10                        -- Focus on top 10 products that are out
-- WHERE Days_Left >= 10 AND Rank_Revenue > 1                              -- Products with safe stock levels

ORDER BY m.Store_ID, m.Rank_Revenue desc;




-- How much money is tied up in inventory?

-- OBJECTIVE:
-- This query calculates the total value of inventory currently held across all products, broken down by product category.
-- It helps answer the question: *How much money is tied up in inventory?*

-- The total value is computed using: Stock_On_Hand × Product_Cost
-- A ROLLUP is used to show both category-level and grand total values.

SELECT 
    p.product_category,
    SUM(i.Stock_On_Hand) AS Inventory_Units,                                -- Total units currently in stock
    ROUND(SUM(i.Stock_On_Hand * p.Product_Cost), 2) AS Inventory_Value_MXN  -- Monetary value of stock at cost price
FROM maven_toys.inventory i
LEFT JOIN maven_toys.products p 
    ON i.Product_ID = p.Product_ID
GROUP BY p.product_category WITH ROLLUP;                                     -- Adds a total row at the end
