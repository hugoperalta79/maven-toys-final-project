-- 2 ) Understand structure of: products

		-- Show all Products
			SELECT *
			FROM maven_toys.products;

		-- Check that there are no duplicates
			SELECT mtp.product_id, count(*) as N_Products
			From maven_toys.products mtp
			Group by 1
			Having N_Products > 1;
            

		-- count the number of products: - 35
			SELECT count(*) FROM maven_toys.products mtp;
            
        -- count the number of products names: - 35    so each product has it own name
			SELECT count(distinct mtp.Product_Name) FROM maven_toys.products mtp;
            
		 -- count the number of categories: - 5   
			SELECT count(distinct product_category) FROM maven_toys.products mtp;

		-- list the categories: - Toys Art & Crafts / Games / Electronics / Sports & Outdoors  
			SELECT distinct product_category FROM maven_toys.products mtp;
            
         -- Avg Cost of the Product : -    $10.25
			SELECT round(avg(Product_Cost), 2) FROM maven_toys.products mtp;   

		 -- Avg price of the Product : -    $14.76
			SELECT round(avg(Product_price), 2) FROM maven_toys.products mtp; 


		-- most expensive price of a Product : -    $39.99
			SELECT round(max(Product_price), 2) FROM maven_toys.products mtp; 
            
            
		-- most expensive Product name : 'Lego Bricks'
			with TopPrice as (
					SELECT	round(max(Product_price), 2)
                    FROM	maven_toys.products mtp)
	
			SELECT mtp.Product_Name
			FROM	maven_toys.products mtp
            Where mtp.Product_price = (Select * from TopPrice); 
            
            
		-- List of Product with PRice over AVG  : 17 products over 35
        With avgPrice as (
			SELECT round(avg(Product_price), 2) FROM maven_toys.products
            )
		SELECT *
        FROM maven_toys.products mtp
        where Product_price >= (SELECT * FROM avgPrice)
        Order by Product_price desc;
        
		-- Most Used Price: - 19.99 having 5 products
         With CountPrices as (
			SELECT Product_Price, count(*) as Nproducts ,
            dense_rank() over(order by count(*) desc) as ranking
            FROM maven_toys.products
            GROUP BY 1
            )
		SELECT Product_Price, Nproducts
         FROM CountPrices
        where ranking = 1;
        
        -- List of the product that have the most used price:
            With CountPrices as (
				SELECT Product_Price, count(*) as Nproducts ,
				dense_rank() over(order by count(*) desc) as ranking
				FROM maven_toys.products
				GROUP BY 1
				)
		SELECT mtp.Product_Name, mtp.Product_Price
         FROM maven_toys.products mtp
        where mtp.Product_Price = (SELECT Product_Price  FROM CountPrices WHERE ranking = 1);
