SELECT * FROM maven_toys.stores;

-- small correction to the store name:
UPDATE maven_toys.stores
SET Store_Name = REPLACE(Store_Name, 'Maven Toys ', '');


/* Phase 1: Get to Know Your Data ✅ */ 

-- 1)  Understand structure of: STORES

		-- a) Total Number of Stores:
			SELECT COUNT(*) FROM maven_toys.stores;
			-- 50 total stores

		-- b) confirm that store table is a dimension with no duplicates values:
			SELECT COUNT(DISTINCT Store_ID) FROM maven_toys.stores; -- Confirms Store_ID is a proper dimension table since the total is the same as the count rows total
            SELECT store_ID as PK, count(*) as Total_Stores
            FROM maven_toys.stores
            GROUP BY 1
            having Total_Stores > 1; -- if result is empty means do duplicates and a good dim table 

			SELECT COUNT(DISTINCT Store_Name) FROM maven_toys.stores;
			-- 50 unique store names - no duplicates

			SELECT COUNT(DISTINCT Store_City) FROM maven_toys.stores;
			-- Stores are spread across 29 different cities

			SELECT COUNT(DISTINCT Store_Location) FROM maven_toys.stores;
			-- Stores are distributed across 4 different location types

			-- All at the same time :
			SELECT 
				COUNT(*) AS Total_N_Stores,
				COUNT(DISTINCT Store_ID) AS Total_Stores_confirm,
				COUNT(DISTINCT Store_Name) AS Total_Stores_names,
				COUNT(DISTINCT Store_City) AS Total_Cities,
				COUNT(DISTINCT Store_Location) AS Total_locations
			FROM
				maven_toys.stores;

-- 1 a) Check the list of the cities - 29 as the result

			SELECT DISTINCT Store_City AS Cities FROM maven_toys.stores
			order by Store_City;
	
-- 1 b) Check the list of the Location - 4 diferente locations Airport / Commercial / Downtown / Residential

			SELECT DISTINCT Store_Location AS Location FROM maven_toys.stores
				order by Store_Location; 
	
-- 	1 c) Check the Location with the greatest number of stores - DownTown With 29 Stores
                With 
					Location_TotalStores as (
							SELECT Store_Location AS Location, COUNT(*) AS total_stores,
							rank() over(order by COUNT(*) desc) as ranking
							FROM maven_toys.stores
							group by 1
							order by total_stores desc)
                
              SELECT location, total_stores
              FROM  Location_TotalStores
              where ranking = 1;
                
-- 1.d) Explore city distribution: which cities have the most stores?

				WITH Tstores AS (
				  SELECT Store_City, COUNT(*) AS total_stores
				  FROM maven_toys.stores
				  GROUP BY Store_City
				),
                
				MTstores AS (
				  SELECT MAX(total_stores) AS maxstores
				  FROM Tstores
				),
                
				TopCities AS (
				  SELECT Store_City
				  FROM Tstores
				  WHERE total_stores = (SELECT maxstores FROM MTstores)
				)
                
				-- Result 1: max number of stores in one city - 4 
					SELECT (SELECT maxstores FROM MTstores) AS max_stores_in_city,

				-- Result 2: number of cities that have that max - 3
					   (SELECT COUNT(*) FROM TopCities) AS number_of_top_cities,

				-- Result 3: list of those cities - Guadalajara, Monterrey, Cuidad de Mexico
					   (SELECT GROUP_CONCAT(Store_City SEPARATOR ', ') FROM TopCities) AS top_cities;
