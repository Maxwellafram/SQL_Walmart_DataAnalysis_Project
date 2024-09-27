--CREATE A DATABASE
CREATE DATABASE Portfolio_Project;

--USE DATABASE
USE Portfolio_Project;

/*Data Wrangling:** This is the first step where inspection of data is done to make sure **NULL** values 
and missing values are detected and data replacement methods are used to replace, missing or **NULL** values.*/

SELECT *
FROM [MBA].[Walmart_Sales_Data];



--Change Column Names to Match records
 EXEC SP_RENAME '[MBA].[Walmart_Sales_Data].TOTAL',
 'Total_Sales', 'Column'

 EXEC SP_RENAME '[MBA].[Walmart_Sales_Data].Tax_5',
 'Tax', 'Column'

 EXEC SP_RENAME '[MBA].[Walmart_Sales_Data].Payment',
 'Payment_Type', 'Column'


SELECT *
FROM MBA.Walmart_Sales_Data
WHERE  [Invoice_ID]  IS NULL OR
	   [Branch] IS NULL OR
       [City]  IS NULL OR
       [Customer_type]  IS NULL OR
       [Gender]  IS NULL OR
       [Product_line]  IS NULL OR
       [Unit_price]  IS NULL OR
       [Quantity]  IS NULL OR
       [Tax]  IS NULL OR
       [Total_Sales]  IS NULL OR
       [Date]  IS NULL OR
       [Time]  IS NULL OR
       [Payment_Type]  IS NULL OR
       [cogs]  IS NULL OR
       [gross_margin_percentage]  IS NULL OR
       [gross_income]  IS NULL OR
       [Rating] IS NULL;
 


 --A. Add a new column named `time_of_day` to give insight of sales in the Morning, Afternoon and Evening. 
 --This will help answer the question on which part of the day most sales are made.


--Add the column Time_of_day 
ALTER TABLE [MBA].[Walmart_Sales_Data]
 ADD Time_of_Day  VARCHAR(20);



 --Check to ensures the right records goes into the table
SELECT [Time],
		CASE 
		WHEN [Time] BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN [Time] BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day
FROM MBA.Walmart_Sales_Data;



--Insertion of records into the column (Time_of_day)
UPDATE MBA.Walmart_Sales_Data
SET [Time_of_Day] = (CASE 
		WHEN [Time] BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN [Time] BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening' 
		END );


--TESTING
 SELECT * 
 FROM MBA.Walmart_Sales_Data
 WHERE [Time_of_Day] = 'MORNING';



 --Add a new column named `day_name` that contains the extracted days of the week on which the given transaction took place 
 --(Mon, Tue, Wed, Thur, Fri). This will help answer the question on which week of the day each branch is busiest.


 --Add the column Day_Name 
ALTER TABLE [MBA].[Walmart_Sales_Data]
ADD Day_Name Varchar(20);



--Check to ensures the right records goes into the table
SELECT DATENAME(WEEKDAY, Date) AS Day_of_week
FROM
MBA.Walmart_Sales_Data;



--Insertion of records into the column (Day_Name)
UPDATE MBA.Walmart_Sales_Data
SET [Day_Name] = DATENAME(WEEKDAY, Date);



--TESTING
 SELECT * 
 FROM MBA.Walmart_Sales_Data
 WHERE [Day_Name] = 'Saturday';



--Add a new column named `month_name` that contains the extracted months of the year on which the given 
--transaction took place (Jan, Feb, Mar). Help determine which month of the year has the most sales and profit.

 --Add the column Month_Name 
ALTER Table MBA.Walmart_Sales_Data
ADD Month_Name Varchar(20);



--Check to ensures the right records goes into the table
SELECT DATENAME(MONTH,Date) AS Month_Name
FROM
MBA.Walmart_Sales_Data;



--Insertion of records into the column (Month_Name)
UPDATE MBA.Walmart_Sales_Data
SET [Month_Name] = DATENAME(MONTH,Date);



--TESTING
 SELECT * 
 FROM MBA.Walmart_Sales_Data
 WHERE [Month_Name] like '%Feb%';
 
 
 
 
 --Business Questions To Answer

--A.Generic Question

--1. How many unique cities does the data have?

SELECT Count(DISTINCT City) AS City_Count
FROM 
[MBA].[Walmart_Sales_Data];


--2. In which city is each branch?

SELECT DISTINCT City,
Branch
FROM 
[MBA].[Walmart_Sales_Data];

--B. Product

--1. How many unique product lines does the data have?
SELECT Count(DISTINCT Product_line) AS Product_Line_Cnt
FROM 
[MBA].[Walmart_Sales_Data];



--2. What is the most common payment method?
SELECT Top 1 [Payment_Type], 
Count([Payment_Type]) AS Payment_Type_Cnt
FROM 
[MBA].[Walmart_Sales_Data]
Group By [Payment_Type]
Order by 2 Desc;


--3. What is the most selling product line?
SELECT Top 1 [Product_line], 
Count([Product_line]) AS Payment_Type_Cnt
FROM 
[MBA].[Walmart_Sales_Data]
GROUP BY [Product_line]
ORDER BY 2 Desc;


--4. What is the total revenue by month?
SELECT [Month_Name],
SUM([Total_Sales] ) As Total_Revenue
FROM 
[MBA].[Walmart_Sales_Data]
GROUP BY [Month_Name];



--5. What month had the largest COGS?

SELECT TOP 1 [Month_Name], 
MAX(cogs) AS Largest_COGs
FROM 
[MBA].[Walmart_Sales_Data]
GROUP BY [Month_Name]
ORDER BY 2 Desc;



--6. What product line had the largest revenue?

SELECT Top 1 Product_line, 
MAX([Total_Sales]) AS Largest_Revenue
FROM 
[MBA].[Walmart_Sales_Data]
GROUP BY Product_line
ORDER BY 2 Desc;

--7. What is the city with the largest revenue?

SELECT Top 1 City, 
MAX([Total_Sales]) AS Largest_Revenue
FROM 
[MBA].[Walmart_Sales_Data]
GROUP BY City
ORDER BY 2 Desc;



--8. What product line had the largest TAX?

SELECT Top 1 Product_line, 
MAX([Tax]) AS Largest_Tax
FROM 
[MBA].[Walmart_Sales_Data]
GROUP BY Product_line
ORDER BY 2 Desc;



--9. Fetch each product line and add a column to those product line showing "Good", "Bad". 
--Good if its greater than average sales

SELECT  TOP 10 [Product_line] , 
		[Total_Sales],
		CASE
				WHEN [Total_Sales] > (SELECT AVG([Total_Sales]) FROM [MBA].[Walmart_Sales_Data]) 
				THEN 'Good'
				ELSE 'Bad'
				END AS Sales_Performance
FROM
[MBA].[Walmart_Sales_Data];



--10. Which branch sold more products than average product sold?

WITH Average_Sales AS
(
SELECT AVG([Quantity]) AS Average_Quantity
FROM
MBA.Walmart_Sales_Data
)

SELECT Branch, 
	Sum([Quantity]) AS Total_Quantity
FROM MBA.Walmart_Sales_Data
GROUP BY Branch
HAVING Sum([Quantity]) > (SELECT AVG([Quantity]) AS Average_Quantity
FROM Average_Sales);



--11. What is the most common product line by gender?

SELECT TOP 1 
	Product_line,
	Gender,
	COUNT(Product_line) AS Product_line_Cnt
	FROM [MBA].[Walmart_Sales_Data]
	GROUP BY Product_line,Gender
	ORDER BY 3 Desc


--12. What is the average rating of each product line?

SELECT 
	Product_line,
	Avg(Rating) AS Average_Rating
	FROM [MBA].[Walmart_Sales_Data]
	GROUP BY Product_line



	--### Sales

--1. Number of sales made in each time of the day per weekday

SELECT [Time_of_Day],
COUNT([Total_Sales])/5 AS Number_of_Sales_Per_Weekday
FROM
(
SELECT 
	[Total_Sales],
	[Time_of_Day]
FROM
MBA.Walmart_Sales_Data
WHERE [Day_Name] IN ('Monday', 'Tuesday','Wednesday','Thursday','Friday')
) AS Sale_by_Time
Group by [Time_of_Day]
ORDER BY 2 DESC
 
--2. Which of the customer types brings the most revenue?

SELECT  TOP 1
[Customer_type],
SUM([Total_Sales]) AS Most_Revenue
FROM
(
SELECT 
	[Total_Sales],
	Customer_type
FROM
MBA.Walmart_Sales_Data
) AS Most_Revenue
GROUP BY Customer_type
ORDER BY 2 DESC


--3. Which city has the largest tax ?

SELECT TOP 1
City,
SUM([Tax]) AS Largest_Tax
FROM
MBA.Walmart_Sales_Data
GROUP BY City
ORDER BY 2 DESC

--4. Which customer type pays the most in TAX?

SELECT TOP 1
Customer_type,
SUM([Tax]) AS Most_Tax
FROM
MBA.Walmart_Sales_Data
GROUP BY Customer_type
ORDER BY 2 DESC
  


--### Customer

--1. How many unique customer types does the data have?

SELECT
		COUNT(DISTINCT [Customer_type] ) AS Customer_type_Cnt
FROM
MBA.Walmart_Sales_Data



--2. How many unique payment methods does the data have?

SELECT
		COUNT(DISTINCT [Payment_Type] ) AS Payment_type_Cnt
FROM
MBA.Walmart_Sales_Data


--3. What is the most common customer type?

SELECT	TOP 1
		[Customer_type],
		COUNT (Customer_type) AS Customer_type_Cnt
FROM
MBA.Walmart_Sales_Data
GROUP BY Customer_type
ORDER BY 2 DESC


--4. Which customer type buys the most?

SELECT	TOP 1
		[Customer_type],
		SUM ([Quantity]) AS Quantity_Cnt
FROM
MBA.Walmart_Sales_Data
GROUP BY Customer_type
ORDER BY 2 DESC


--5. What is the gender of most of the customers?

SELECT  TOP 1
		Gender,
		COUNT(Gender) AS Gender_Cnt
FROM
MBA.Walmart_Sales_Data
GROUP BY Gender
ORDER BY 2 DESC



--6. What is the gender distribution per branch?

SELECT  
		Branch,
		Gender,
		COUNT(Gender) AS Gender_Cnt
FROM
MBA.Walmart_Sales_Data
GROUP BY Branch,Gender
ORDER BY 1 


--7. Which time of the day do customers give most ratings?

SELECT	TOP 1
		[Time_of_Day],
		SUM(Rating) AS Total_Ratings
FROM
MBA.Walmart_Sales_Data
GROUP BY [Time_of_Day] 
ORDER BY 2 DESC

--8. Which time of the day do customers give most ratings per branch?

SELECT  TOP 3
		[Time_of_Day],
		Branch,
		SUM(Rating) AS Total_Ratings
FROM
MBA.Walmart_Sales_Data
GROUP BY [Time_of_Day] , Branch
ORDER BY 3 DESC

--9. Which day fo the week has the best avg ratings?

SELECT  TOP 1
		[Day_Name],
		AVG(Rating) AS AVG_Ratings
FROM
MBA.Walmart_Sales_Data
GROUP BY [Day_Name]
ORDER BY 2 DESC

--10. Which day of the week has the best average ratings per branch?

SELECT * FROM
(SELECT 
		[Day_Name], 
		Branch,
		AVG(Rating) AS AVG_Ratings,
		DENSE_RANK () OVER (ORDER BY AVG(Rating) DESC) AS Ranking
FROM
MBA.Walmart_Sales_Data 
GROUP BY [Day_Name], Branch) as Results
WHERE Ranking IN (1,2,3)


SELECT *
FROM
MBA.Walmart_Sales_Data