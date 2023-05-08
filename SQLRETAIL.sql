
CREATE DATABASE RETAIL

SELECT *
FROM Customer

SELECT *
FROM prod_cat_info

SELECT *
FROM Transactions


--Q1
SELECT COUNT(*) AS ROWS_CUSTOMER
FROM CUSTOMER 
 
SELECT COUNT(*) AS ROWS_PRODUCT
FROM prod_cat_info 
 
SELECT COUNT(*) AS ROWS_TRANSACTION
FROM Transactions

--Q2
SELECT COUNT(*) AS NO_OF_RETURN
FROM Transactions
WHERE total_amt < '0'

--Q3
SELECT CONVERT(DATE,DOB,105) AS DATES FROM CUSTOMER


--Q4
SELECT DATEDIFF(DD, MIN(tran_date),MAX(tran_date) ) AS DAYS_,
       DATEDIFF(MM, MIN(tran_date),MAX(tran_date) ) AS MONTHS,
       DATEDIFF(YY, MIN(tran_date),MAX(tran_date) ) AS YEARS
FROM Transactions

--Q5
SELECT prod_cat
FROM prod_cat_info
WHERE prod_subcat='DIY'


--DATA ANALYSIS

--Q1
SELECT TOP 1 Store_Type
FROM
(
SELECT 
Store_type,count(store_type) AS COUNTS
from Transactions
group by Store_type 
) AS X
ORDER BY COUNTS DESC



--Q2
SELECT 
COUNT(CASE WHEN Gender='M' THEN 1 END) MALE,
COUNT(CASE WHEN Gender='F' THEN 1 END) FEMALE
FROM CUSTOMER

--Q3
SELECT TOP 1 city_code, COUNT(CUSTOMER_ID) AS COUNTS
FROM CUSTOMER
GROUP BY city_code
ORDER BY COUNTS DESC

--Q4
SELECT COUNT(PROD_SUBCAT) AS SUB_CAT_BOOKS
FROM prod_cat_info
WHERE prod_cat='Books'

--Q5
SELECT prod_cat,MAX(CAST(QTY AS INT)) AS MAX_QTY
FROM Transactions AS A
LEFT JOIN prod_cat_info AS B
ON A.PROD_CAT_CODE=B.PROD_CAT_CODE
GROUP BY prod_cat

      --OR
SELECT PROD_CAT_CODE,MAX(CAST(QTY AS INT)) AS MAX_QTY
FROM Transactions
GROUP BY prod_cat_code

--Q6
SELECT SUM(CAST(TOTAL_AMT AS FLOAT)) AS TOTAL_REVENUE
FROM Transactions AS A
LEFT JOIN prod_cat_info AS B
ON A.PROD_CAT_CODE=B.PROD_CAT_CODE
AND A.prod_subcat_code=B.prod_sub_cat_code
WHERE prod_cat IN ('Books','Electronics')



--Q7
SELECT COUNT(*)
FROM
(
SELECT cust_id, COUNT(cust_id) AS Count_of_Transactions
FROM Transactions
WHERE Qty >= 0
GROUP BY cust_id
HAVING COUNT(cust_id) > 10
) AS X

--Q8
SELECT SUM(CAST(TOTAL_AMT AS FLOAT)) AS TOTAL_REVENUE,Store_type
FROM Transactions AS A
LEFT JOIN prod_cat_info AS B
ON A.PROD_CAT_CODE=B.PROD_CAT_CODE
AND A.prod_subcat_code=B.prod_sub_cat_code
WHERE prod_cat IN ('Electronics','Clothing')
GROUP BY Store_type
HAVING Store_type='Flagship Store'



--Q9
SELECT prod_subcat as SUB_CAT, SUM(CAST(TOTAL_AMT AS FLOAT)) as TOTL_REVENUE
FROM Transactions
LEFT JOIN Customer
  ON Transactions.cust_id = Customer.customer_ID
 
LEFT JOIN [Prod_cat_info]
  ON [Transactions].[prod_cat_code] = [Prod_cat_info].[prod_cat_code]
  AND Transactions.prod_subcat_code=prod_cat_info.prod_sub_cat_code
WHERE Gender like 'M' and prod_Cat IN ('Electronics')
group by [prod_subcat]

--Q10

SELECT TOP 5 PERCENT_SALE,PERCENT_RETURN,prod_subcat
FROM
(
	SELECT prod_subcat,
	SUM(CASE WHEN (CAST(TOTAL_AMT AS FLOAT)) > 0 THEN 1 ELSE 0 END) AS TOTAL_SALES,
	SUM(CASE WHEN (CAST(TOTAL_AMT AS FLOAT)) < 0 THEN 1 ELSE 0 END) AS TOTAL_RETURN,
	(SUM(CASE WHEN (CAST(TOTAL_AMT AS FLOAT)) > 0 THEN 1 ELSE 0 END)/SUM(CAST(TOTAL_AMT AS FLOAT))*100 ) AS PERCENT_SALE,
	(SUM(CASE WHEN (CAST(TOTAL_AMT AS FLOAT)) < 0 THEN 1 ELSE 0 END)/SUM(CAST(TOTAL_AMT AS FLOAT))*100 ) AS PERCENT_RETURN
	FROM Transactions AS A 
	JOIN prod_cat_info AS B
	ON A.prod_cat_code=B.prod_cat_code
	GROUP BY prod_subcat) AS X
ORDER BY TOTAL_SALES DESC


 --Q11
SELECT CUST_ID,SUM(CAST(TOTAL_AMT AS FLOAT)) AS REVENUE
FROM Transactions
LEFT JOIN Customer
ON Transactions.cust_id = Customer.customer_ID
WHERE tran_date BETWEEN dateadd(DAY, -30 ,(SELECT MAX(tran_date) FROM Transactions))
AND   (SELECT MAX(tran_date) FROM Transactions)
AND DATEDIFF(YEAR,CONVERT(DATE,DOB,103),GETDATE()) BETWEEN 25 AND 35
GROUP BY CUST_ID



--Q12
Select Top 1 prod_cat
From
 (SELECT Count(CAST(TOTAL_AMT AS FLOAT))as sales1,prod_cat,tran_date
 FROM Transactions AS A
 INNER JOIN prod_cat_info AS B
 ON A.prod_cat_code=B.prod_cat_code
 WHERE total_amt<'0'
 GROUP BY prod_cat,tran_date
 HAVING tran_date BETWEEN dateadd(month, -3 ,(SELECT MAX(tran_date) FROM Transactions)) AND 
 (SELECT MAX(tran_date) FROM Transactions)
 ) as X
 ORDER BY sales1 DESC
  
--Q13
SELECT TOP 1 SUM(CAST(TOTAL_AMT AS FLOAT)) AS SALES_AMT, SUM(CAST(QTY AS INT)) AS QUANTITY,Store_type
FROM Transactions
GROUP BY Store_type
ORDER BY SALES_AMT DESC, QUANTITY DESC


--Q14
SELECT AVG(CAST(TOTAL_AMT AS FLOAT)) AS AVG_REVENUE ,prod_cat_code
FROM Transactions
GROUP BY prod_cat_code 
HAVING AVG(CAST(TOTAL_AMT AS FLOAT)) >(SELECT (AVG(CAST(TOTAL_AMT AS FLOAT))) FROM Transactions)

 

--Q15
SELECT AVG(CAST(TOTAL_AMT AS FLOAT)) AS AVG_REVENUE,
SUM(CAST(TOTAL_AMT AS FLOAT)) AS SALES_AMT,
prod_subcat,prod_cat
FROM Transactions 
INNER JOIN [prod_cat_info]
ON Transactions.prod_cat_code=prod_cat_info.prod_cat_code
AND Transactions.prod_subcat_code=prod_cat_info.prod_sub_cat_code
WHERE prod_cat IN
(
SELECT TOP 5 prod_cat
FROM Transactions 
INNER JOIN [prod_cat_info]
ON Transactions.prod_cat_code=prod_cat_info.prod_cat_code
AND Transactions.prod_subcat_code=prod_cat_info.prod_sub_cat_code
GROUP BY prod_cat
ORDER BY SUM(CAST(TOTAL_AMT AS FLOAT)) DESC
)
GROUP BY prod_subcat,prod_cat

