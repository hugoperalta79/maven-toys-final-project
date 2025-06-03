SELECT * FROM maven_toys.stores;


-- 3 ) Understand structure of: SALES

SELECT * FROM SALES;

WITH
    NTransaction AS (
        SELECT COUNT(*) AS total_transactions FROM SALES ),
    FirstSaleDate AS (
        SELECT MIN(Date) AS fsalesdate FROM SALES ),
	LastSaleDate AS (
        SELECT MAX(Date) AS fsalesdate FROM SALES ),
	Totaldays as (
		select (datediff(MAX(Date), MIN(Date) ) + 1 ) as salesDays FROM SALES ),
	Totaldays2 as (
		SELECT count(*) as salesday2 from 
        (SELECT distinct Date from sales ) as distdays ),
	totalSales as (
    SELECT sum(total) as totalsaless from (
    SELECT s.Sale_ID, s.Date, s.Store_ID, s.Units, p.Product_Name, p.Product_Cost, p.Product_Price, (s.Units*p.Product_Price) as total
    FROM	Sales s
    left join products p
    on s.Product_ID = p.Product_ID) as totalsales
    ),
    
totalperday as (
	SELECT date, sum(total) as totalsaless from (
    SELECT s.Sale_ID, s.Date, s.Store_ID, s.Units, p.Product_Name, p.Product_Cost, p.Product_Price, (s.Units*p.Product_Price) as total
    FROM	Sales s
    left join products p
    on s.Product_ID = p.Product_ID) as totalsales
    GROUP BY 1
    ),

AVGperday as (
	SELECT avg(totalsaless) as AvgSalesPerDay
    FROM	totalperday ),
    

Count_Uniqueproducts as (
	SELECT Count(*) as c_UniqueP FROM (
			SELECT distinct Product_ID FROM SALES ) as Uniqueproducts
    ),
    
Count_Uniquestores as (
	SELECT Count(*) as c_UniqueS FROM (
			SELECT distinct Store_ID FROM SALES ) as UniqueStores
    )
    

SELECT
    (SELECT FORMAT(total_transactions,0) FROM NTransaction) AS "@N Transactions", -- '829 262'
    (SELECT CONCAT('MXN$ ', FORMAT(totalsaless, 2)) fROM totalSales ) as "@total Sales",
    (SELECT DATE_FORMAT(fsalesdate, '%Y-%m-%d') FROM FirstSaleDate) AS "1st Trans date", -- 2022-01-01
    (SELECT DATE_FORMAT(fsalesdate, '%Y-%m-%d') FROM LastSaleDate) AS "last Trans date", -- 2023-09-30
    (SELECT salesDays FROM Totaldays) AS "total days", -- 638
    (SELECT salesday2 FROM Totaldays2 ) AS "total days2",-- 638 days in business from thses 2 columns we can say that there were sales every day for 638 days. no Gaps
    (SELECT FORMAT(  (SELECT total_transactions FROM NTransaction) / (SELECT salesDays FROM Totaldays), 0 )) AS "Avg transactions per day", -- 1300
    (SELECT CONCAT('MXN$ ', FORMAT(AvgSalesPerDay,2)) FROM AVGperday ) AS "Avg sales per day", -- 22 640 dollars
    (SELECT c_UniqueP FROM Count_Uniqueproducts) as "# unique products sold" , -- 35. meaning all products were sold form the product table. no products without sales
    (SELECT  c_UniqueS FROM Count_Uniquestores) as "# unique Stores" -- 50 meaning all stores old at lesat one product during the life time of this company
    ;
    
  
  -- TOP3 STORE SALES
  SELECT * FROM (
			SELECT Store_Name, CONCAT('MXN$ ', format(sum(total), 2)) as totalsaless,
				row_number() over(order by CONCAT('MXN$ ', format(sum(total), 2)) desc) as ranking2
			FROM (
				SELECT sl.Sale_ID, sl.Store_ID, sl.Units, st.Store_Name, (sl.Units*p.Product_Price) as total
				FROM	Sales sl
				left join stores st on sl.Store_ID = st.Store_ID
				left join products p on sl.Product_ID = p.Product_ID
				) as totalsales
			GROUP BY 1
            ) as ranktable
	Where ranking2 < 4;

-- TOP3 Best-Selling Product by Volume
SELECT p.Product_Name, format(SUM(s.Units), 0) AS total_units, CONCAT('MXN$ ', format(SUM(s.Units * p.Product_Price), 2 ) ) AS total_sales, CONCAT('MXN$ ', format(SUM(s.Units * p.Product_Price) / SUM(s.Units), 2 ) )  as AvgUnitPrice
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
GROUP BY p.Product_Name
ORDER BY SUM(s.Units) DESC
LIMIT 3;




-- TOP3 Best-Selling Product by Revenue
SELECT 
  p.Product_Name,
  CONCAT('MXN$ ', FORMAT(SUM(s.Units * p.Product_Price), 2)) AS total_sales,
  FORMAT(SUM(s.Units), 0) AS total_units,
  CONCAT('MXN$ ', FORMAT(SUM(s.Units * p.Product_Price) / SUM(s.Units), 2)) AS AvgUnitPrice
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
GROUP BY p.Product_Name
ORDER BY SUM(s.Units * p.Product_Price) DESC
LIMIT 3;


  -- TOP3 DAYS SALES

SELECT 
  Date, 
  CONCAT('MXN$ ', FORMAT(SUM(Units * Product_Price), 2)) AS total
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
GROUP BY Date
ORDER BY SUM(Units * Product_Price) DESC
LIMIT 3;


with 
top3days as (
SELECT 
  Date, 
  CONCAT('MXN$ ', FORMAT(SUM(Units * Product_Price), 2)) AS total
FROM Sales s
JOIN Products p ON s.Product_ID = p.Product_ID
GROUP BY Date
ORDER BY SUM(Units * Product_Price) DESC
LIMIT 3)



SELECT sl.date, sl.Sale_ID, sl.Store_ID, sl.Units, st.Store_Name, (sl.Units*p.Product_Price) as total
FROM	Sales sl
left join stores st on sl.Store_ID = st.Store_ID
left join products p on sl.Product_ID = p.Product_ID
				 ;




	SELECT s.Product_ID, p.Product_Name, CONCAT('MXN$ ', format(SUM(s.Units * p.Product_Price), 2 ) ) AS total_sales, sum(s.Units) as tUnits
    FROM	Sales s
    left join products p
    on s.Product_ID = p.Product_ID
    Group by 1, 2;
