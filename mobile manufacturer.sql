--SQL Advance Case Study


--Q1--BEGIN 
	

SELECT DISTINCT [STATE] 
FROM FACT_TRANSACTIONS A
INNER JOIN DIM_LOCATION B
ON A.IDLOCATION= B.IDLOCATION
WHERE [Date] BETWEEN '01-01-2005' AND (SELECT (MAX([DATE])) FROM DIM_DATE)

--Q1--END

--Q2--BEGIN

SELECT TOP 1 [STATE] ,COUNT(QUANTITY)
FROM FACT_TRANSACTIONS A
INNER JOIN DIM_LOCATION B
ON A.IDLOCATION= B.IDLOCATION
INNER JOIN DIM_MODEL C
ON A.IDModel=C.IDModel
INNER JOIN DIM_MANUFACTURER D
ON C.IDManufacturer=D.IDManufacturer
WHERE  Manufacturer_Name='Samsung' AND Country='US'
GROUP BY [STATE] 
ORDER BY COUNT(QUANTITY) DESC

--Q2--END

--Q3--BEGIN      
	
SELECT COUNT([IDCustomer]) AS NO_TRANSACTION,[Model_Name],[ZipCode],[State] 
FROM FACT_TRANSACTIONS A
LEFT JOIN DIM_LOCATION B
ON A.IDLOCATION= B.IDLOCATION
LEFT JOIN DIM_MODEL C
ON A.IDModel=C.IDModel
GROUP BY [Model_Name], [ZipCode],[State] 

--Q3--END

--Q4--BEGIN

SELECT TOP 1 [Model_Name],[Unit_Price]
FROM DIM_MODEL 
ORDER BY [Unit_Price] ASC

--Q4--END

--Q5--BEGIN

SELECT MODEL_NAME,AVG(UNIT_PRICE) AS AVERAGE_PRICE
FROM DIM_MODEL X 
LEFT JOIN DIM_MANUFACTURER Y
ON X.IDManufacturer=Y.IDManufacturer
WHERE Manufacturer_Name IN
(
	SELECT TOP 5 MANUFACTURER_NAME
	FROM FACT_TRANSACTIONS A
	INNER JOIN DIM_MODEL B
	ON A.IDModel=B.IDModel
	INNER JOIN DIM_MANUFACTURER C
	ON B.IDManufacturer=C.IDManufacturer
	GROUP BY Manufacturer_Name
	ORDER BY SUM(Quantity) DESC
)
GROUP BY Model_Name
ORDER BY AVERAGE_PRICE DESC


--Q5--END

--Q6--BEGIN

SELECT Customer_Name,AVG(TotalPrice) AS AVG_AMOUNT
FROM FACT_TRANSACTIONS A
RIGHT JOIN DIM_CUSTOMER B
ON A.IDCustomer=B.IDCustomer
RIGHT JOIN DIM_DATE C
ON A.[Date]=C.[DATE]
WHERE [YEAR] = 2009
GROUP BY Customer_Name
HAVING AVG(TotalPrice)>'500'

--Q6--END

--Q7--BEGIN  

SELECT * FROM (
SELECT * FROM (
SELECT TOP 5 MODEL_NAME FROM DIM_MODEL
LEFT JOIN (
SELECT IDModel,SUM(Quantity) AS SUM_QTY FROM DIM_DATE
LEFT JOIN FACT_TRANSACTIONS
ON DIM_DATE.DATE=FACT_TRANSACTIONS.Date
WHERE YEAR=2008
GROUP BY IDModel) AS A
ON DIM_MODEL.IDModel=A.IDModel
ORDER BY SUM_QTY DESC

INTERSECT

SELECT TOP 5 MODEL_NAME FROM DIM_MODEL
LEFT JOIN (
SELECT IDModel,SUM(Quantity) AS SUM_QTY FROM DIM_DATE
LEFT JOIN FACT_TRANSACTIONS
ON DIM_DATE.DATE=FACT_TRANSACTIONS.Date
WHERE YEAR=2009
GROUP BY IDModel) AS A
ON DIM_MODEL.IDModel=A.IDModel
ORDER BY SUM_QTY DESC ) AS X

INTERSECT 

SELECT TOP 5 MODEL_NAME FROM DIM_MODEL
LEFT JOIN (
SELECT IDModel,SUM(Quantity) AS SUM_QTY FROM DIM_DATE
LEFT JOIN FACT_TRANSACTIONS
ON DIM_DATE.DATE=FACT_TRANSACTIONS.Date
WHERE YEAR=2010
GROUP BY IDModel) AS A
ON DIM_MODEL.IDModel=A.IDModel
ORDER BY SUM_QTY DESC ) AS Y


--Q7--END	
--Q8--BEGIN

SELECT TOP 1*
FROM 
(
SELECT TOP 2 IDManufacturer , [year], SUM(totalprice*quantity) as totalsales
from DIM_MODEL as A
LEFT JOIN FACT_TRANSACTIONS AS B
ON A.IDModel=B.IDModel
LEFT JOIN DIM_DATE AS C 
ON B.Date=C.DATE
WHERE [YEAR] =2009
GROUP BY IDManufacturer, [YEAR]
ORDER BY totalsales DESC
)
as A 
UNION 
SELECT TOP 1*
FROM
(
SELECT TOP 2 IDManufacturer , [year], SUM(totalprice*quantity) as totalsales
from DIM_MODEL as A
LEFT JOIN FACT_TRANSACTIONS AS B
ON A.IDModel=B.IDModel
LEFT JOIN DIM_DATE AS C 
ON B.Date=C.DATE
WHERE [YEAR] =2010
GROUP BY IDManufacturer, [YEAR]
ORDER BY totalsales DESC
)
AS A


--Q8--END

--Q9--BEGIN
	
SELECT MANUFACTURER_NAME
FROM DIM_MANUFACTURER AS X
INNER JOIN DIM_MODEL AS Y
ON X.IDMANUFACTURER= Y.IDMANUFACTURER
INNER JOIN FACT_TRANSACTIONS AS Z
ON Y.IDMODEL= Z.IDMODEL
WHERE YEAR([DATE]) = 2010 
EXCEPT 
SELECT MANUFACTURER_NAME
FROM DIM_MANUFACTURER AS X
INNER JOIN DIM_MODEL AS Y
ON X.IDMANUFACTURER= Y.IDMANUFACTURER
INNER JOIN FACT_TRANSACTIONS AS Z
ON Y.IDMODEL= Z.IDMODEL
WHERE YEAR([DATE]) = 2009


--Q9--END

--Q10--BEGIN


SELECT IDCustomer, YEARS, AVG_QTY, AVG_SP, (( AVG_SP-PREVIOUS)/PREVIOUS*100) AS PERCENT_CHANGE
FROM
(
SELECT IDCustomer, YEARS, AVG_QTY, AVG_SP,
LAG(AVG_SP,1) OVER (PARTITION BY IDCustomer ORDER BY IDCustomer ASC, YEARS ASC) AS PREVIOUS 
FROM 
(
SELECT X.IDCustomer, YEARS, AVG_QTY, X.AVG_SP FROM 
        ( SELECT TOP 10 IDCustomer, AVG(TotalPrice) AS AVG_SP FROM FACT_TRANSACTIONS
		GROUP BY IDCustomer
		ORDER BY AVG_SP DESC ) AS X
LEFT JOIN 
(
	    SELECT IDCustomer, YEAR(DATE) AS YEARS,AVG(TotalPrice) AS AVG_SP , AVG(QUANTITY) AS AVG_QTY 
		FROM FACT_TRANSACTIONS
        GROUP BY IDCustomer , YEAR(DATE)) AS Y
		
ON X.IDCustomer=Y.IDCustomer ) AS A) AS B

--Q10--END
	