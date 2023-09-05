SELECT *
FROM sales

SELECT *
FROM inventory

SELECT *
FROM stores

SELECT *
FROM products


SELECT REPLACE(Product_Cost,'$',''),REPLACE(Product_Price,'$','')
FROM products

UPDATE products 
SET Product_Cost= REPLACE(Product_Cost,'$',''),Product_Price=REPLACE(Product_Price,'$','')


--Looking for duplicates Sales to make sure join is correct
SELECT COUNT(Sale_ID)
FROM products p JOIN sales s
	ON p.Product_ID=s.Product_ID
JOIN inventory i 
	ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
GROUP BY Sale_ID
HAVING COUNT(Sale_ID)>1


--Q1.What is the top-selling products in terms of revenue?--

--Calculating Overall Profit
CREATE TABLE #OverallProf(TotalProfit FLOAT)
INSERT INTO #OverallProf

SELECT SUM((CAST(p.Product_Price AS FLOAT)-CAST(p.Product_Cost AS FLOAT))*s.Units)
FROM products p JOIN sales s
	ON p.Product_ID=s.Product_ID
JOIN inventory i 
	ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
SELECT* FROM #OverallProf


--Using Overall Profit to calculate Profit Margin of each Product
SELECT p.Product_ID,p.Product_Name,SUM((CAST(p.Product_Price AS FLOAT)-CAST(p.Product_Cost AS FLOAT))*s.Units) AS Revenue,(SUM((CAST(p.Product_Price AS FLOAT)-CAST(p.Product_Cost AS FLOAT))*s.Units))*100/(SELECT* FROM #OverallProf) AS [Profit Margin]
FROM products p JOIN sales s
	ON p.Product_ID=s.Product_ID
JOIN inventory i 
	ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
GROUP BY p.Product_ID,p.Product_Name
ORDER BY 3 DESC
--Thiss will give the company insights on which products that arent performing well 
--Anything in range 0.5%-3.5 is typical for reailers


--Q2.What is the top-selling products in terms of units?-----

--Calculating product popuality measured on Unit sales
CREATE TABLE [MostPopItemByUnitWithRev](Product_ID int,Product_Name VARCHAR(40),[Units Sold] INt,Profit FLOAT)
INSERT INTO [MostPopItemByUnitWithRev]

SELECT p.Product_ID,p.Product_Name,SUM(s.Units) AS [Popular Product],SUM((CAST(p.Product_Price AS FLOAT)-CAST(p.Product_Cost AS FLOAT))*s.Units) AS Profit
FROM products p JOIN sales s
	ON p.Product_ID=s.Product_ID
JOIN inventory i 
	ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
GROUP BY p.Product_ID,p.Product_Name
ORDER BY 3 DESC
--Gives insight to Customer Preferences 
--Gives insight to Product Development

---Q3.How does the sales performance vary across different store cities?---------

--Calculating Profit per City
SELECT Store_City,SUM((CAST(p.Product_Price AS FLOAT)-CAST(p.Product_Cost AS FLOAT))*s.Units) AS Profit
FROM products p JOIN sales s
	ON p.Product_ID=s.Product_ID
JOIN inventory i 
	ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
JOIN stores 
	ON stores.Store_ID=s.Store_ID
GROUP BY Store_City
ORDER BY 2 DESC
--Gives insight Sales Disparities

--Calculating Total units sold by Catagory and City in relatoion to month
SELECT Product_Category,st.Store_City,DATENAME(MONTH,Date) AS Seasons,SUM(Units) AS [Units Sold]
FROM products p JOIN sales s
	ON p.Product_ID=s.Product_ID
JOIN inventory i 
	ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
JOIN stores st
	ON st.Store_ID=s.Store_ID
GROUP BY Product_Category,DATENAME(MONTH,Date),st.Store_City
ORDER BY 1,2
--Seasonal Popuality and Seasonal Sales can be used in Tine Series Analysis
--Market Segmentation
--Total Profit by Catagory and City

SELECT Product_Category,st.Store_City,SUM((CAST(p.Product_Price AS FLOAT)-CAST(p.Product_Cost AS FLOAT))*s.Units) AS Profit
FROM products p JOIN sales s
	ON p.Product_ID=s.Product_ID
JOIN inventory i 
	ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
JOIN stores st
	ON st.Store_ID=s.Store_ID
GROUP BY Product_Category,st.Store_City
ORDER BY 1,2
--Seasonal Popuality and Seasonal Sales can be used in Tine Series Analysis
--Market Segmentation


--Q4--Are there any seasonal trends in transactions in data?-----

--Calculating Total transactions made
SELECT Date,COUNT(s.Sale_ID) AS [Number Of Transactions]
FROM products p JOIN sales s
	ON p.Product_ID=s.Product_ID
JOIN inventory i 
	ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
JOIN stores st
	ON st.Store_ID=s.Store_ID
GROUP BY Date
ORDER BY 1,2
--Can be used in Time Series Analysis to dertermine Seasonal patterns
--can be used to forecast for staffing (Busy times of the year)

----Q5--Can you identify any correlation between product category and sales performance?--

SELECT Product_Category,SUM(Units) AS [Units Sold],SUM((CAST(p.Product_Price AS FLOAT)-CAST(p.Product_Cost AS FLOAT))*s.Units) AS Profit
FROM products p JOIN sales s
	ON p.Product_ID=s.Product_ID
JOIN inventory i 
	ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
GROUP BY Product_Category
ORDER BY 2 DESC
--Identify Top Performers

--Q6- Are there any products with consistently low stock levels? How does this impact sales?--
SELECT Date,i.Store_ID,p.Product_ID,i.Stock_On_Hand,s.Units
FROM products p JOIN sales s
	ON p.Product_ID=s.Product_ID
JOIN inventory i 
	ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
WHERE i.Store_ID=1
ORDER BY i.Store_ID,p.Product_ID
--Time series of stock on hand againts units purchadsed to determine products which are overstocked also to forecast stocks in the future
--Inventory Optimization

--However in this case this data doesnt change Stock_On_Hand so no insights can be gained

--Q7--How does the store's location or opening date correlate with its sales performance?---

SELECT Y.Store_ID,Y.[Days open],X.Profit
FROM

	(SELECT DISTINCT(s.Store_ID),DATEDIFF(DAY,'2018-09-30',st.Store_Open_Date)*-1 AS [Days open]
	FROM products p JOIN sales s
		ON p.Product_ID=s.Product_ID
	JOIN inventory i 
		ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
	JOIN stores	st 
		ON s.Store_ID=st.Store_ID) AS Y
JOIN 
	(SELECT s.Store_ID,SUM((CAST(p.Product_Price AS FLOAT)-CAST(p.Product_Cost AS FLOAT))*s.Units) AS Profit
	FROM products p JOIN sales s
		ON p.Product_ID=s.Product_ID
	JOIN inventory i 
		ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
	GROUP BY s.Store_ID) AS X
ON Y.Store_ID=X.Store_ID
ORDER BY 3 DESC 
--How the stores opening date effects profit
--Gives the company an idea of Growth Over Time also Early Success



--Q8--Are there certain product categories that perform better in specific store?--
CREATE TABLE ##RevPerStorePerCat(Store_ID int,Product_Category VARCHAR(40),Profit float)

INSERT INTO ##RevPerStorePerCat
SELECT st.Store_ID,p.Product_Category,SUM((CAST(p.Product_Price AS FLOAT)-CAST(p.Product_Cost AS FLOAT))*s.Units) AS Profit
FROM products p JOIN sales s
		ON p.Product_ID=s.Product_ID
	JOIN inventory i 
		ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
	JOIN stores	st 
		ON s.Store_ID=st.Store_ID
GROUP BY st.Store_ID,p.Product_Category
ORDER BY st.Store_ID,p.Product_Category


CREATE TABLE #MaxRev(Store_ID int,[MaxRev] float)

INSERT INTO #MaxRev
SELECT Rev.Store_ID,MAX(Rev.Profit)
FROM ##RevPerStorePerCat Rev
GROUP BY Store_ID


SELECT Product_Category,COUNT(Rev.Store_ID)
FROM #MaxRev Rev
LEFT JOIN 
##RevPerStorePerCat RevPer
	ON RevPer.Store_ID=Rev.Store_ID AND RevPer.Profit=Rev.MaxRev
GROUP BY Product_Category
--Counts number of times each product catergory has reached maximim revenue over all stores
--Toys very frequently performce the best followed by Electronics

---Q9--Is there a relationship between product price and sales volume?-
SELECT p.Product_ID,p.Product_Price,SUM(s.Units) AS [Number Of Units]
FROM products p JOIN sales s
		ON p.Product_ID=s.Product_ID
	JOIN inventory i 
		ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
	JOIN stores	st 
		ON s.Store_ID=st.Store_ID
GROUP BY p.Product_Price,p.Product_ID
ORDER BY 2 DESC
--If price change was recorded could calculate the Price sensetivity for each product to maximise profit


---Q10-Can you identify any products that consistently underperform across all stores?-

CREATE TABLE #StoreProductProf(Product_ID int,Store_ID int,Profit FLOAT)
INSERT INTO #StoreProductProf
SELECT p.Product_ID,st.Store_ID,SUM((CAST(p.Product_Price AS FLOAT)-CAST(p.Product_Cost AS FLOAT))*s.Units) AS Profit
FROM products p JOIN sales s
		ON p.Product_ID=s.Product_ID
	JOIN inventory i 
		ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
	JOIN stores	st 
		ON s.Store_ID=st.Store_ID
GROUP BY p.Product_ID,st.Store_ID


SELECT * FROM #StoreProductProf


CREATE TABLE #min(Store_ID int,Profit float)

INSERT INTO #min
SELECT Store_ID,MIN(Profit) AS [Min Profit]
FROM
#StoreProductProf 
GROUP BY Store_ID

--counts the number of times the same product has the lowest revenue across all stores
SELECT #StoreProductProf.Product_ID,COUNT(#StoreProductProf.Product_ID)
FROM #min JOIN #StoreProductProf
	ON #min.Store_ID=#StoreProductProf.Store_ID
WHERE #min.Profit=#StoreProductProf.Profit
GROUP BY #StoreProductProf.Product_ID
---Product 33 frequently performs poorly across all stores

--Q11--Can you determine the performace of each stores product catergory?-
--Counts the number of times a store is 50% below product catergory avaerage profit
SELECT Y.Store_ID,COUNT(Y.Store_ID)
FROM 
(SELECT p.Product_Category,SUM((CAST(p.Product_Price AS FLOAT)-CAST(p.Product_Cost AS FLOAT))*s.Units)/(50) AS AVGProfit
FROM products p JOIN sales s
		ON p.Product_ID=s.Product_ID
	JOIN inventory i 
		ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
	JOIN stores	st 
		ON s.Store_ID=st.Store_ID
GROUP BY p.Product_Category) X
JOIN
(SELECT st.Store_ID,p.Product_Category,SUM((CAST(p.Product_Price AS FLOAT)-CAST(p.Product_Cost AS FLOAT))*s.Units) AS Profit
FROM products p JOIN sales s
		ON p.Product_ID=s.Product_ID
	JOIN inventory i 
		ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
	JOIN stores	st 
		ON s.Store_ID=st.Store_ID
GROUP BY st.Store_ID,p.Product_Category) Y
ON X.Product_Category=Y.Product_Category
WHERE Y.Profit<0.5*X.AVGProfit
GROUP BY  Y.Store_ID

--Q12--What is the overall trend in sales over time? Is it increasing, decreasing, or stable?-

--Profit each day
CREATE TABLE ProfTimeSeries (Date DATETIME,Profit FLOAT)
INSERT INTO ProfTimeSeries

SELECT Date,SUM((CAST(p.Product_Price AS FLOAT)-CAST(p.Product_Cost AS FLOAT))*s.Units) AS Profit
FROM products p JOIN sales s
ON p.Product_ID=s.Product_ID
JOIN inventory i 
ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
GROUP BY Date
ORDER BY Date
--Insights on Market Saturation
--Inshits on Business Performance as a whole 

--Q13--Is there a correlation between the store's opening date and its sales performance?
SELECT Y.Store_ID,Y.[Days open],X.Profit
FROM
	(SELECT DISTINCT(s.Store_ID),DATEDIFF(DAY,'2018-09-30',st.Store_Open_Date)*-1 AS [Days open]
	FROM products p JOIN sales s
		ON p.Product_ID=s.Product_ID
	JOIN inventory i 
		ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
	JOIN stores	st 
		ON s.Store_ID=st.Store_ID) AS Y
JOIN 
	(SELECT s.Store_ID,SUM((CAST(p.Product_Price AS FLOAT)-CAST(p.Product_Cost AS FLOAT))*s.Units) AS Profit
	FROM products p JOIN sales s
		ON p.Product_ID=s.Product_ID
	JOIN inventory i 
		ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
	GROUP BY s.Store_ID) AS X
ON Y.Store_ID=X.Store_ID
ORDER BY 3 DESC 

--Determines a model for a new stores performance 

---Q14---What are the most profitable product categories, and which are the least profitable?
SELECT p.Product_Category,SUM((CAST(p.Product_Price AS FLOAT)-CAST(p.Product_Cost AS FLOAT))*s.Units) AS Profit
FROM products p JOIN sales s
		ON p.Product_ID=s.Product_ID
	JOIN inventory i 
		ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
GROUP BY p.Product_Category
ORDER BY 2 DESC
--Most is Toys
--Least is Sports & Outdoors

---Q15--Are there any products with high production costs but low sales?

--Procuct cost and volume of sales
SELECT p.Product_ID,Product_Cost,SUM(Units) [Units Sold]
FROM products p JOIN sales s
		ON p.Product_ID=s.Product_ID
	JOIN inventory i 
		ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
	JOIN stores	st 
		ON s.Store_ID=st.Store_ID
GROUP BY p.Product_ID,Product_Cost
ORDER BY 3 DESC
--Gives insights on tied up capital in company

----Q16---Can you identify any products with consistently declining sales or popularity?

SELECT p.Product_ID,s.Date,SUM((CAST(p.Product_Price AS FLOAT)-CAST(p.Product_Cost AS FLOAT))*s.Units) AS Profit
FROM products p JOIN sales s
		ON p.Product_ID=s.Product_ID
	JOIN inventory i 
		ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
	JOIN stores	st 
		ON s.Store_ID=st.Store_ID
GROUP BY p.Product_ID,s.Date
ORDER BY 1,2 
--Time series on product profit over time 
--Product sales plot each product see pattern in revenue


---Q17--What is the monthly or quarterly sales performance for each store?
SELECT DATEPART(YY,s.Date) AS Year,DATEPART(QQ,s.Date) AS Quater,st.Store_ID,SUM((CAST(p.Product_Price AS FLOAT)-CAST(p.Product_Cost AS FLOAT))*s.Units) AS Profit
FROM products p JOIN sales s
		ON p.Product_ID=s.Product_ID
	JOIN inventory i 
		ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
	JOIN stores	st 
		ON s.Store_ID=st.Store_ID
GROUP BY st.Store_ID,DATEPART(YY,s.Date),DATEPART(QQ,s.Date)
ORDER BY st.Store_ID,DATEPART(YY,s.Date),DATEPART(QQ,s.Date)
--Perform a Time Series Analysis and look at profits per quater

---Q18---How do sales vary on weekends compared to weekdays?

SELECT DATENAME(WEEKDAY,Date) AS [Day of week],SUM(Units)
FROM products p JOIN sales s
	ON p.Product_ID=s.Product_ID
JOIN inventory i 
	ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
WHERE Date BETWEEN '2017-01-01' AND '2017-12-31'
GROUP BY DATENAME(WEEKDAY,Date)
ORDER BY 2 DESC

SELECT DATENAME(WEEKDAY,Date) AS [Day of week],COUNT(s.Sale_ID)
FROM products p JOIN sales s
	ON p.Product_ID=s.Product_ID
JOIN inventory i 
	ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
WHERE Date BETWEEN '2017-01-01' AND '2017-12-31'
GROUP BY DATENAME(WEEKDAY,Date)
ORDER BY 2 DESC
--Gives insight on staffing with the number of transactions 
--Insight on stock required 

---Q19--What is the average transaction size (units and revenue) for each store?-
--Average Profit
SELECT AVG(X.Profit)
FROM 
(SELECT s.Sale_ID,Date,SUM((CAST(p.Product_Price AS FLOAT)-CAST(p.Product_Cost AS FLOAT))*s.Units) AS Profit
FROM 
products p JOIN sales s
	ON p.Product_ID=s.Product_ID
JOIN inventory i 
	ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
JOIN stores	st 
	ON s.Store_ID=st.Store_ID
GROUP BY  s.Sale_ID,Date) X

--Average Units
SELECT AVG(X.Units)
FROM 
(SELECT s.Sale_ID,Date,SUM(s.Units) AS Units
FROM 
products p JOIN sales s
	ON p.Product_ID=s.Product_ID
JOIN inventory i 
	ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
JOIN stores	st 
	ON s.Store_ID=st.Store_ID
GROUP BY  s.Sale_ID,Date) X


----Q20---How does the price-to-cost ratio affect sales and profit?
SELECT p.Product_ID,(SUM(p.Product_Cost*s.Units))/(SUM((CAST(p.Product_Price AS FLOAT)-CAST(p.Product_Cost AS FLOAT))*s.Units))
FROM 
products p JOIN sales s
	ON p.Product_ID=s.Product_ID
JOIN inventory i 
	ON s.Store_ID=i.Store_ID AND s.Product_ID=i.Product_ID
JOIN stores	st 
	ON s.Store_ID=st.Store_ID
GROUP BY p.Product_ID
ORDER BY 2 DESC